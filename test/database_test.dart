import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/models/vocabulary_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_database_crud.db';
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

  group('AppDatabase Unit & Integration Tests', () {
    test('Database seeds initial IELTS vocabularies and computes stats', () async {
      final vocabs = await AppDatabase.instance.getAllVocabularies();
      expect(vocabs.length, greaterThanOrEqualTo(5));

      final stats = await AppDatabase.instance.getStats();
      expect(stats['total'], greaterThanOrEqualTo(5));
      expect(stats['speaking'], greaterThan(0));
      expect(stats['writing'], greaterThan(0));
      expect(stats['general'], greaterThan(0));
      expect(stats['basic'], greaterThan(0));
      expect(stats['advance'], greaterThan(0));
    });

    test('Database CRUD operations work properly with Basic/Advance level', () async {
      final now = DateTime.now();
      final newVocab = Vocabulary(
        word: 'Ephemeral',
        meaning: 'Berlangsung singkat / fana',
        level: 'Advance',
        phonetic: "/ɪ'fem.ər.əl/",
        definition: 'Lasting for a very short time.',
        example: 'Fame in the internet age can be ephemeral.',
        exampleTranslation: 'Ketenaran di era internet bisa berlangsung singkat.',
        partOfSpeech: 'Adjective',
        usageCategories: ['Writing', 'Speaking'],
        topics: ['Culture', 'Society'],
        notes: 'Useful in essays comparing modern media trends.',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      // 1. Insert
      final insertedId = await AppDatabase.instance.insertVocabulary(newVocab);
      expect(insertedId, isNonZero);

      // 2. Read by ID
      final fetched = await AppDatabase.instance.getVocabularyById(insertedId);
      expect(fetched, isNotNull);
      expect(fetched!.word, 'Ephemeral');
      expect(fetched.level, 'Advance');
      expect(fetched.isAdvance, isTrue);
      expect(fetched.isBasic, isFalse);
      expect(fetched.phonetic, "/ɪ'fem.ər.əl/");
      expect(fetched.isFavorite, isFalse);

      // 3. Update
      final updated = fetched.copyWith(
        level: 'Basic',
        meaning: 'Sangat singkat',
      );
      final updateRows = await AppDatabase.instance.updateVocabulary(updated);
      expect(updateRows, 1);

      final reFetched = await AppDatabase.instance.getVocabularyById(insertedId);
      expect(reFetched!.level, 'Basic');
      expect(reFetched.isBasic, isTrue);
      expect(reFetched.meaning, 'Sangat singkat');

      // 4. Toggle Favorite
      await AppDatabase.instance.toggleFavorite(insertedId, false);
      final favorited = await AppDatabase.instance.getVocabularyById(insertedId);
      expect(favorited!.isFavorite, isTrue);

      await AppDatabase.instance.toggleFavorite(insertedId, true);
      final unfavorited = await AppDatabase.instance.getVocabularyById(insertedId);
      expect(unfavorited!.isFavorite, isFalse);

      // 5. Delete
      final deleteRows = await AppDatabase.instance.deleteVocabulary(insertedId);
      expect(deleteRows, 1);
      final afterDelete = await AppDatabase.instance.getVocabularyById(insertedId);
      expect(afterDelete, isNull);
    });

    test('updateVocabulary throws ArgumentError when id is null', () async {
      final now = DateTime.now();
      final invalidVocab = Vocabulary(
        id: null,
        word: 'Test',
        meaning: 'Uji',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () async => await AppDatabase.instance.updateVocabulary(invalidVocab),
        throwsArgumentError,
      );
    });

    test('getRecentVocabularies respects limit and created_at ordering', () async {
      final recent = await AppDatabase.instance.getRecentVocabularies(limit: 3);
      expect(recent.length, lessThanOrEqualTo(3));
      if (recent.length >= 2) {
        expect(
          recent[0].createdAt.isAfter(recent[1].createdAt) ||
              recent[0].createdAt.isAtSameMomentAs(recent[1].createdAt),
          isTrue,
        );
      }
    });

    test('getVocabularyById returns null for non-existing id', () async {
      final nonExistent = await AppDatabase.instance.getVocabularyById(999999);
      expect(nonExistent, isNull);
    });

    test('Custom topics add, duplicate ignore, get, and delete', () async {
      // Add custom topic
      await AppDatabase.instance.addCustomTopic('Psychology');
      var topics = await AppDatabase.instance.getCustomTopics();
      expect(topics.contains('Psychology'), isTrue);

      // Adding duplicate should not throw or duplicate
      await AppDatabase.instance.addCustomTopic('Psychology');
      topics = await AppDatabase.instance.getCustomTopics();
      expect(topics.where((t) => t == 'Psychology').length, 1);

      // Adding empty topic should be ignored
      await AppDatabase.instance.addCustomTopic('   ');
      topics = await AppDatabase.instance.getCustomTopics();
      expect(topics.any((t) => t.trim().isEmpty), isFalse);

      // Delete custom topic
      await AppDatabase.instance.deleteCustomTopic('Psychology');
      topics = await AppDatabase.instance.getCustomTopics();
      expect(topics.contains('Psychology'), isFalse);
    });
  });
}
