import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../models/vocabulary_model.dart';

// Database Instance Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// All Vocabularies Async Notifier
class VocabularyNotifier extends AsyncNotifier<List<Vocabulary>> {
  @override
  Future<List<Vocabulary>> build() async {
    final db = ref.watch(databaseProvider);
    return await db.getAllVocabularies();
  }

  Future<void> loadVocabularies() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      return await db.getAllVocabularies();
    });
  }

  Future<int> addVocabulary(Vocabulary vocab) async {
    final db = ref.read(databaseProvider);
    final id = await db.insertVocabulary(vocab);
    await loadVocabularies();
    return id;
  }

  Future<void> updateVocabulary(Vocabulary vocab) async {
    final db = ref.read(databaseProvider);
    await db.updateVocabulary(vocab);
    await loadVocabularies();
  }

  Future<void> toggleFavorite(int id, bool currentStatus) async {
    final db = ref.read(databaseProvider);
    await db.toggleFavorite(id, currentStatus);
    await loadVocabularies();
  }

  Future<void> deleteVocabulary(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteVocabulary(id);
    await loadVocabularies();
  }
}

final vocabularyNotifierProvider =
    AsyncNotifierProvider<VocabularyNotifier, List<Vocabulary>>(
  VocabularyNotifier.new,
);

// Filter State Class
class VocabularyFilter {
  final String query;
  final String? selectedLevel; // null = All, 'Basic', 'Advance'
  final String? selectedUsage; // null = All, 'Speaking', 'Writing', 'General'
  final String? selectedTopic; // null = All topics
  final bool onlyFavorites;
  final VocabularySort sort;

  const VocabularyFilter({
    this.query = '',
    this.selectedLevel,
    this.selectedUsage,
    this.selectedTopic,
    this.onlyFavorites = false,
    this.sort = VocabularySort.newest,
  });

  VocabularyFilter copyWith({
    String? query,
    String? Function()? selectedLevel,
    String? Function()? selectedUsage,
    String? Function()? selectedTopic,
    bool? onlyFavorites,
    VocabularySort? sort,
  }) {
    return VocabularyFilter(
      query: query ?? this.query,
      selectedLevel:
          selectedLevel != null ? selectedLevel() : this.selectedLevel,
      selectedUsage:
          selectedUsage != null ? selectedUsage() : this.selectedUsage,
      selectedTopic:
          selectedTopic != null ? selectedTopic() : this.selectedTopic,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      sort: sort ?? this.sort,
    );
  }
}

// Filter State Notifier
class VocabularyFilterNotifier extends Notifier<VocabularyFilter> {
  @override
  VocabularyFilter build() => const VocabularyFilter();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setLevel(String? level) {
    state = state.copyWith(selectedLevel: () => level);
  }

  void setUsage(String? usage) {
    state = state.copyWith(selectedUsage: () => usage);
  }

  void setTopic(String? topic) {
    state = state.copyWith(selectedTopic: () => topic);
  }

  void toggleOnlyFavorites() {
    state = state.copyWith(onlyFavorites: !state.onlyFavorites);
  }

  void setOnlyFavorites(bool val) {
    state = state.copyWith(onlyFavorites: val);
  }

  void setSort(VocabularySort sort) {
    state = state.copyWith(sort: sort);
  }

  void reset() {
    state = const VocabularyFilter();
  }
}

final vocabularyFilterProvider =
    NotifierProvider<VocabularyFilterNotifier, VocabularyFilter>(
  VocabularyFilterNotifier.new,
);

// Filtered Vocabularies Provider
final filteredVocabulariesProvider = Provider<List<Vocabulary>>((ref) {
  final vocabState = ref.watch(vocabularyNotifierProvider);
  final filter = ref.watch(vocabularyFilterProvider);

  return vocabState.maybeWhen(
    data: (allVocabs) {
      var list = List<Vocabulary>.from(allVocabs);

      // Search Query Filter
      if (filter.query.trim().isNotEmpty) {
        final q = filter.query.trim().toLowerCase();
        list = list.where((v) {
          final wordMatches = v.word.toLowerCase().contains(q);
          final meaningMatches = v.meaning.toLowerCase().contains(q);
          final defMatches = v.definition?.toLowerCase().contains(q) ?? false;
          final notesMatches = v.notes?.toLowerCase().contains(q) ?? false;
          return wordMatches || meaningMatches || defMatches || notesMatches;
        }).toList();
      }

      // Level Filter (Basic vs Advance)
      if (filter.selectedLevel != null) {
        list = list
            .where((v) =>
                v.level.toLowerCase() == filter.selectedLevel!.toLowerCase())
            .toList();
      }

      // Usage Filter
      if (filter.selectedUsage != null) {
        list = list.where((v) => v.hasUsage(filter.selectedUsage!)).toList();
      }

      // Topic Filter
      if (filter.selectedTopic != null) {
        list = list.where((v) => v.hasTopic(filter.selectedTopic!)).toList();
      }

      // Favorites Filter
      if (filter.onlyFavorites) {
        list = list.where((v) => v.isFavorite).toList();
      }

      // Sort
      if (filter.sort == VocabularySort.newest) {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        list.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
      }

      return list;
    },
    orElse: () => [],
  );
});

// Statistics Provider
class VocabularyStats {
  final int total;
  final int speaking;
  final int writing;
  final int general;
  final int basic;
  final int advance;
  final int favorites;

  const VocabularyStats({
    this.total = 0,
    this.speaking = 0,
    this.writing = 0,
    this.general = 0,
    this.basic = 0,
    this.advance = 0,
    this.favorites = 0,
  });
}

final vocabularyStatsProvider = Provider<VocabularyStats>((ref) {
  final vocabState = ref.watch(vocabularyNotifierProvider);

  return vocabState.maybeWhen(
    data: (vocabs) {
      int speaking = 0;
      int writing = 0;
      int general = 0;
      int basic = 0;
      int advance = 0;
      int favorites = 0;

      for (final v in vocabs) {
        if (v.hasUsage('Speaking')) speaking++;
        if (v.hasUsage('Writing')) writing++;
        if (v.hasUsage('General')) general++;
        if (v.isBasic) basic++;
        if (v.isAdvance) advance++;
        if (v.isFavorite) favorites++;
      }

      return VocabularyStats(
        total: vocabs.length,
        speaking: speaking,
        writing: writing,
        general: general,
        basic: basic,
        advance: advance,
        favorites: favorites,
      );
    },
    orElse: () => const VocabularyStats(),
  );
});

// Recent Vocabularies Provider (top 5)
final recentVocabulariesProvider = Provider<List<Vocabulary>>((ref) {
  final vocabState = ref.watch(vocabularyNotifierProvider);

  return vocabState.maybeWhen(
    data: (vocabs) {
      final sorted = List<Vocabulary>.from(vocabs)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(5).toList();
    },
    orElse: () => [],
  );
});

// Custom Topics Provider
class CustomTopicsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final db = ref.watch(databaseProvider);
    return await db.getCustomTopics();
  }

  Future<void> loadTopics() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      return await db.getCustomTopics();
    });
  }

  Future<void> addTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return;
    final db = ref.read(databaseProvider);
    await db.addCustomTopic(trimmed);
    await loadTopics();
  }
}

final customTopicsProvider =
    AsyncNotifierProvider<CustomTopicsNotifier, List<String>>(
  CustomTopicsNotifier.new,
);

// Combined Topics Provider (Default + Custom Topics)
final allTopicsProvider = Provider<List<String>>((ref) {
  final customTopicsAsync = ref.watch(customTopicsProvider);
  final customList = customTopicsAsync.maybeWhen(
    data: (list) => list,
    orElse: () => <String>[],
  );

  final set = <String>{...AppConstants.defaultTopics};
  set.addAll(customList);
  return set.toList();
});
