import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/constants/app_constants.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/models/vocabulary_model.dart';
import 'package:my_vocabulary/providers/theme_provider.dart';
import 'package:my_vocabulary/providers/vocabulary_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_provider.db';
  });

  setUp(() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppDatabase.dbName);
    await AppDatabase.instance.close();
    await databaseFactory.deleteDatabase(path);
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  group('Provider & State Management Unit Tests', () {
    test('themeModeProvider toggles between light and dark mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('VocabularyFilterNotifier updates filter criteria and resets', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filterNotifier = container.read(vocabularyFilterProvider.notifier);

      expect(container.read(vocabularyFilterProvider).query, '');
      expect(container.read(vocabularyFilterProvider).selectedLevel, isNull);
      expect(container.read(vocabularyFilterProvider).selectedUsage, isNull);
      expect(container.read(vocabularyFilterProvider).selectedTopic, isNull);
      expect(container.read(vocabularyFilterProvider).onlyFavorites, isFalse);
      expect(container.read(vocabularyFilterProvider).sort, VocabularySort.newest);

      // Set query
      filterNotifier.setQuery('mitigate');
      expect(container.read(vocabularyFilterProvider).query, 'mitigate');

      // Set level
      filterNotifier.setLevel('Advance');
      expect(container.read(vocabularyFilterProvider).selectedLevel, 'Advance');

      // Set usage
      filterNotifier.setUsage('Writing');
      expect(container.read(vocabularyFilterProvider).selectedUsage, 'Writing');

      // Set topic
      filterNotifier.setTopic('Environment');
      expect(container.read(vocabularyFilterProvider).selectedTopic, 'Environment');

      // Toggle favorites
      filterNotifier.toggleOnlyFavorites();
      expect(container.read(vocabularyFilterProvider).onlyFavorites, isTrue);

      // Set sort
      filterNotifier.setSort(VocabularySort.alphabetical);
      expect(container.read(vocabularyFilterProvider).sort, VocabularySort.alphabetical);

      // Reset
      filterNotifier.reset();
      expect(container.read(vocabularyFilterProvider).query, '');
      expect(container.read(vocabularyFilterProvider).selectedLevel, isNull);
      expect(container.read(vocabularyFilterProvider).selectedUsage, isNull);
      expect(container.read(vocabularyFilterProvider).selectedTopic, isNull);
      expect(container.read(vocabularyFilterProvider).onlyFavorites, isFalse);
      expect(container.read(vocabularyFilterProvider).sort, VocabularySort.newest);
    });

    test('VocabularyNotifier and filteredVocabulariesProvider CRUD operations', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Initial build loads seeded vocabularies
      final initial = await container.read(vocabularyNotifierProvider.future);
      expect(initial.length, greaterThanOrEqualTo(5));

      // 2. Add a new vocabulary
      final now = DateTime.now();
      final newVocab = Vocabulary(
        word: 'Plausible',
        meaning: 'Masuk akal / beralasan',
        level: 'Advance',
        definition: 'Seeming reasonable or probable.',
        example: 'A plausible explanation was offered.',
        exampleTranslation: 'Penjelasan yang masuk akal telah diberikan.',
        partOfSpeech: 'Adjective',
        usageCategories: const ['Writing'],
        topics: const ['Education'],
        notes: 'Good for academic argument discussion.',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      final addedId = await container
          .read(vocabularyNotifierProvider.notifier)
          .addVocabulary(newVocab);
      expect(addedId, isNonZero);

      var all = await container.read(vocabularyNotifierProvider.future);
      expect(all.any((v) => v.word == 'Plausible'), isTrue);

      // 3. Toggle favorite
      await container
          .read(vocabularyNotifierProvider.notifier)
          .toggleFavorite(addedId, false);
      all = await container.read(vocabularyNotifierProvider.future);
      final favoritedItem = all.firstWhere((v) => v.id == addedId);
      expect(favoritedItem.isFavorite, isTrue);

      // 4. Test Filter: Query search
      container.read(vocabularyFilterProvider.notifier).setQuery('plausible');
      var filtered = container.read(filteredVocabulariesProvider);
      expect(filtered.length, 1);
      expect(filtered.first.word, 'Plausible');

      // Test Filter: Level filter
      container.read(vocabularyFilterProvider.notifier).reset();
      container.read(vocabularyFilterProvider.notifier).setLevel('Basic');
      filtered = container.read(filteredVocabulariesProvider);
      expect(filtered.every((v) => v.isBasic), isTrue);

      container.read(vocabularyFilterProvider.notifier).setLevel('Advance');
      filtered = container.read(filteredVocabulariesProvider);
      expect(filtered.every((v) => v.isAdvance), isTrue);

      // Test Filter: Usage filter
      container.read(vocabularyFilterProvider.notifier).reset();
      container.read(vocabularyFilterProvider.notifier).setUsage('Writing');
      filtered = container.read(filteredVocabulariesProvider);
      expect(filtered.every((v) => v.hasUsage('Writing')), isTrue);

      // Test Filter: Favorites filter
      container.read(vocabularyFilterProvider.notifier).reset();
      container.read(vocabularyFilterProvider.notifier).setOnlyFavorites(true);
      filtered = container.read(filteredVocabulariesProvider);
      expect(filtered.every((v) => v.isFavorite), isTrue);

      // Test Sort: Alphabetical
      container.read(vocabularyFilterProvider.notifier).reset();
      container
          .read(vocabularyFilterProvider.notifier)
          .setSort(VocabularySort.alphabetical);
      filtered = container.read(filteredVocabulariesProvider);
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].word.toLowerCase().compareTo(filtered[i + 1].word.toLowerCase()),
          lessThanOrEqualTo(0),
        );
      }

      // 5. Update vocabulary
      final toUpdate = favoritedItem.copyWith(meaning: 'Sangat masuk akal');
      await container
          .read(vocabularyNotifierProvider.notifier)
          .updateVocabulary(toUpdate);
      all = await container.read(vocabularyNotifierProvider.future);
      expect(all.firstWhere((v) => v.id == addedId).meaning, 'Sangat masuk akal');

      // 6. Delete vocabulary
      await container
          .read(vocabularyNotifierProvider.notifier)
          .deleteVocabulary(addedId);
      all = await container.read(vocabularyNotifierProvider.future);
      expect(all.any((v) => v.id == addedId), isFalse);
    });

    test('vocabularyStatsProvider calculates exact counts', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Await database seed
      await container.read(vocabularyNotifierProvider.future);

      final stats = container.read(vocabularyStatsProvider);
      expect(stats.total, greaterThanOrEqualTo(5));
      expect(stats.speaking, greaterThan(0));
      expect(stats.writing, greaterThan(0));
      expect(stats.general, greaterThan(0));
      expect(stats.basic, greaterThan(0));
      expect(stats.advance, greaterThan(0));
    });

    test('customTopicsProvider adds and fetches custom topics', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(customTopicsProvider.future);

      await container
          .read(customTopicsProvider.notifier)
          .addTopic('Astrophysics');
      final topics = await container.read(customTopicsProvider.future);
      expect(topics.contains('Astrophysics'), isTrue);

      final allTopics = container.read(allTopicsProvider);
      expect(allTopics.contains('Astrophysics'), isTrue);
    });
  });
}
