import 'dart:convert';

class Vocabulary {
  final int? id;
  final String word;
  final String meaning;
  final String level; // 'Basic' or 'Advance'
  final String? phonetic; // e.g. /ɪn ə 'nʌt.ʃɛl/
  final String? definition;
  final String? example;
  final String? exampleTranslation;
  final String? partOfSpeech;
  final List<String> usageCategories;
  final List<String> topics;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vocabulary({
    this.id,
    required this.word,
    required this.meaning,
    this.level = 'Advance',
    this.phonetic,
    this.definition,
    this.example,
    this.exampleTranslation,
    this.partOfSpeech,
    this.usageCategories = const ['General'],
    this.topics = const ['Other'],
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Vocabulary copyWith({
    int? id,
    String? word,
    String? meaning,
    String? level,
    String? phonetic,
    String? definition,
    String? example,
    String? exampleTranslation,
    String? partOfSpeech,
    List<String>? usageCategories,
    List<String>? topics,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      level: level ?? this.level,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      usageCategories: usageCategories ?? this.usageCategories,
      topics: topics ?? this.topics,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word.trim(),
      'meaning': meaning.trim(),
      'level': level,
      'phonetic': phonetic?.trim().isEmpty ?? true ? null : phonetic?.trim(),
      'definition': definition?.trim().isEmpty ?? true ? null : definition?.trim(),
      'example': example?.trim().isEmpty ?? true ? null : example?.trim(),
      'example_translation': exampleTranslation?.trim().isEmpty ?? true
          ? null
          : exampleTranslation?.trim(),
      'part_of_speech': partOfSpeech?.trim().isEmpty ?? true ? null : partOfSpeech?.trim(),
      'usage_categories': jsonEncode(usageCategories),
      'topics': jsonEncode(topics),
      'notes': notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }
      return [];
    }

    return Vocabulary(
      id: map['id'] as int?,
      word: map['word'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
      level: map['level'] as String? ?? 'Advance',
      phonetic: map['phonetic'] as String?,
      definition: map['definition'] as String?,
      example: map['example'] as String?,
      exampleTranslation: map['example_translation'] as String?,
      partOfSpeech: map['part_of_speech'] as String?,
      usageCategories: parseList(map['usage_categories']),
      topics: parseList(map['topics']),
      notes: map['notes'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  bool hasUsage(String usage) {
    return usageCategories.any((u) => u.toLowerCase() == usage.toLowerCase());
  }

  bool hasTopic(String topic) {
    return topics.any((t) => t.toLowerCase() == topic.toLowerCase());
  }

  bool get isBasic => level.toLowerCase() == 'basic';
  bool get isAdvance => level.toLowerCase() == 'advance';
}
