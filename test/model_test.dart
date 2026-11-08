import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_vocabulary/models/vocabulary_model.dart';

void main() {
  group('Vocabulary Model Unit Tests', () {
    final now = DateTime.now();

    final testVocab = Vocabulary(
      id: 10,
      word: 'Ubiquitous',
      meaning: 'Ada di mana-mana',
      level: 'Advance',
      phonetic: "/juː'bɪk.wɪ.təs/",
      definition: 'Present everywhere.',
      example: 'Smartphones are ubiquitous.',
      exampleTranslation: 'Smartphone ada di mana-mana.',
      partOfSpeech: 'adj',
      usageCategories: const ['Writing', 'Speaking'],
      topics: const ['Technology', 'Society'],
      notes: 'IELTS Band 8+ vocabulary',
      isFavorite: true,
      createdAt: now,
      updatedAt: now,
    );

    test('Serialization toMap and fromMap roundtrip preserves data', () {
      final map = testVocab.toMap();

      expect(map['id'], 10);
      expect(map['word'], 'Ubiquitous');
      expect(map['meaning'], 'Ada di mana-mana');
      expect(map['level'], 'Advance');
      expect(map['phonetic'], "/juː'bɪk.wɪ.təs/");
      expect(map['is_favorite'], 1);
      expect(jsonDecode(map['usage_categories'] as String), ['Writing', 'Speaking']);
      expect(jsonDecode(map['topics'] as String), ['Technology', 'Society']);

      final restored = Vocabulary.fromMap(map);
      expect(restored.id, testVocab.id);
      expect(restored.word, testVocab.word);
      expect(restored.meaning, testVocab.meaning);
      expect(restored.level, testVocab.level);
      expect(restored.phonetic, testVocab.phonetic);
      expect(restored.definition, testVocab.definition);
      expect(restored.example, testVocab.example);
      expect(restored.exampleTranslation, testVocab.exampleTranslation);
      expect(restored.partOfSpeech, testVocab.partOfSpeech);
      expect(restored.usageCategories, testVocab.usageCategories);
      expect(restored.topics, testVocab.topics);
      expect(restored.notes, testVocab.notes);
      expect(restored.isFavorite, isTrue);
      expect(restored.createdAt.millisecondsSinceEpoch, testVocab.createdAt.millisecondsSinceEpoch);
      expect(restored.updatedAt.millisecondsSinceEpoch, testVocab.updatedAt.millisecondsSinceEpoch);
    });

    test('fromMap parses fallback comma-separated string format', () {
      final map = {
        'id': 1,
        'word': 'Test',
        'meaning': 'Uji',
        'level': 'Basic',
        'usage_categories': 'Speaking, Writing, General',
        'topics': 'Education, Technology',
        'is_favorite': 0,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final vocab = Vocabulary.fromMap(map);
      expect(vocab.usageCategories, ['Speaking', 'Writing', 'General']);
      expect(vocab.topics, ['Education', 'Technology']);
      expect(vocab.isFavorite, isFalse);
    });

    test('hasUsage checks case-insensitively', () {
      expect(testVocab.hasUsage('writing'), isTrue);
      expect(testVocab.hasUsage('WRITING'), isTrue);
      expect(testVocab.hasUsage('Speaking'), isTrue);
      expect(testVocab.hasUsage('General'), isFalse);
    });

    test('hasTopic checks case-insensitively', () {
      expect(testVocab.hasTopic('technology'), isTrue);
      expect(testVocab.hasTopic('TECHNOLOGY'), isTrue);
      expect(testVocab.hasTopic('Society'), isTrue);
      expect(testVocab.hasTopic('Crime'), isFalse);
    });

    test('isBasic and isAdvance getters verify level correctly', () {
      expect(testVocab.isAdvance, isTrue);
      expect(testVocab.isBasic, isFalse);

      final basicVocab = testVocab.copyWith(level: 'Basic');
      expect(basicVocab.isBasic, isTrue);
      expect(basicVocab.isAdvance, isFalse);
    });

    test('copyWith updates specified fields only', () {
      final updated = testVocab.copyWith(
        word: 'Pervasive',
        meaning: 'Menyebar luas',
        isFavorite: false,
      );

      expect(updated.word, 'Pervasive');
      expect(updated.meaning, 'Menyebar luas');
      expect(updated.isFavorite, isFalse);
      // Unchanged fields remain same
      expect(updated.id, testVocab.id);
      expect(updated.level, testVocab.level);
      expect(updated.phonetic, testVocab.phonetic);
      expect(updated.usageCategories, testVocab.usageCategories);
    });
  });
}
