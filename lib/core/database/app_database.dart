import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/vocabulary_model.dart';
import 'database_init.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;
  static String dbName = 'my_vocabulary.db';

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await initializePlatformDatabase();

    final String path = await getPlatformDatabasePath(dbName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Vocabularies Table
    await db.execute('''
      CREATE TABLE vocabularies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        level TEXT NOT NULL DEFAULT 'Advance',
        phonetic TEXT,
        definition TEXT,
        example TEXT,
        example_translation TEXT,
        part_of_speech TEXT,
        usage_categories TEXT NOT NULL,
        topics TEXT NOT NULL,
        notes TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Custom Topics Table
    await db.execute('''
      CREATE TABLE custom_topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Index for quick search and sort
    await db.execute('CREATE INDEX idx_vocab_word ON vocabularies(word)');
    await db.execute('CREATE INDEX idx_vocab_created_at ON vocabularies(created_at DESC)');
    await db.execute('CREATE INDEX idx_vocab_level ON vocabularies(level)');
    await db.execute('CREATE INDEX idx_vocab_favorite ON vocabularies(is_favorite)');

    // Seed initial IELTS vocabulary data matching design mockup
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE vocabularies ADD COLUMN level TEXT NOT NULL DEFAULT 'Advance'",
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vocab_level ON vocabularies(level)',
      );
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE vocabularies ADD COLUMN phonetic TEXT');
      await db.execute(
        'ALTER TABLE vocabularies ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vocab_favorite ON vocabularies(is_favorite)',
      );
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    final starterVocabularies = [
      Vocabulary(
        word: 'In a nutshell',
        meaning: 'Singkatnya / kesimpulannya',
        level: 'Advance',
        phonetic: "/ɪn ə 'nʌt.ʃɛl/",
        definition: 'In a few words; summarized concisely.',
        example: 'In a few words; summarized concisely into the main takeaway.',
        exampleTranslation: 'Singkatnya, terangkum secara ringkas menjadi poin utama.',
        partOfSpeech: 'idiom',
        usageCategories: ['Speaking'],
        topics: ['Part 1-3', 'General'],
        notes: '💡 Advance idiom for IELTS Speaking Part 3 when summarizing a viewpoint.',
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      ),
      Vocabulary(
        word: 'Mitigate',
        meaning: 'Mengurangi / meredakan dampak',
        level: 'Advance',
        phonetic: "/'mɪt.ɪ.ɡeɪt/",
        definition: 'To make something less severe, serious, or painful.',
        example: 'To make something bad or harmful less severe, serious, or painful.',
        exampleTranslation: 'Membuat sesuatu yang buruk atau berbahaya menjadi tidak terlalu parah.',
        partOfSpeech: 'verb',
        usageCategories: ['Writing'],
        topics: ['Task 2', 'Environment'],
        notes: '💡 Advance equivalent of "Reduce / Lessen". Collocations: mitigate climate change, mitigate risks.',
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ),
      Vocabulary(
        word: 'Ubiquitous',
        meaning: 'Ada di mana-mana / merajalela',
        level: 'Advance',
        phonetic: "/juː'bɪk.wɪ.təs/",
        definition: 'Present, appearing, or found everywhere at the same time.',
        example: 'Smartphones have become ubiquitous in modern daily life.',
        exampleTranslation: 'Ponsel pintar telah menjadi hal yang ada di mana-mana dalam kehidupan sehari-hari modern.',
        partOfSpeech: 'adj',
        usageCategories: ['Writing', 'General'],
        topics: ['Technology', 'Society'],
        notes: '💡 Advance equivalent of "Everywhere / Common". Band 8+ vocabulary to describe trends.',
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 20)),
        updatedAt: now.subtract(const Duration(minutes: 20)),
      ),
      Vocabulary(
        word: 'Detrimental',
        meaning: 'Merugikan / berdampak buruk',
        level: 'Advance',
        phonetic: "/ˌdet.rɪ'men.təl/",
        definition: 'Causing harm or damage; having a harmful effect.',
        example: 'Excessive screen time can have a detrimental effect on children\'s eyesight.',
        exampleTranslation: 'Waktu layar yang berlebihan dapat memiliki efek merugikan pada penglihatan anak-anak.',
        partOfSpeech: 'adj',
        usageCategories: ['Writing', 'Speaking'],
        topics: ['Health', 'Education'],
        notes: '💡 Advance equivalent of "Harmful / Bad". Highly recommended for IELTS Task 2 essays.',
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      Vocabulary(
        word: 'Harmful',
        meaning: 'Berbahaya / merusak',
        level: 'Basic',
        phonetic: "/'hɑːm.fəl/",
        definition: 'Causing or likely to cause harm.',
        example: 'Pollution is harmful to the environment.',
        exampleTranslation: 'Polusi berbahaya bagi lingkungan.',
        partOfSpeech: 'adj',
        usageCategories: ['General', 'Speaking'],
        topics: ['Environment', 'Health'],
        notes: '📌 Basic word (Band 5-6). Upgrade to "Detrimental" or "Damaging" for Band 7+ writing.',
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 40)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
      ),
    ];

    for (final vocab in starterVocabularies) {
      await db.insert('vocabularies', vocab.toMap());
    }
  }

  // --- Vocabulary CRUD Operations ---

  Future<int> insertVocabulary(Vocabulary vocab) async {
    final db = await database;
    return await db.insert('vocabularies', vocab.toMap());
  }

  Future<int> updateVocabulary(Vocabulary vocab) async {
    final db = await database;
    if (vocab.id == null) {
      throw ArgumentError('Vocabulary id cannot be null for update.');
    }
    return await db.update(
      'vocabularies',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  Future<void> toggleFavorite(int id, bool currentStatus) async {
    final db = await database;
    await db.update(
      'vocabularies',
      {'is_favorite': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteVocabulary(int id) async {
    final db = await database;
    return await db.delete(
      'vocabularies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Vocabulary?> getVocabularyById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabularies',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Vocabulary.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Vocabulary>> getAllVocabularies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabularies',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Vocabulary.fromMap(map)).toList();
  }

  Future<List<Vocabulary>> getRecentVocabularies({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabularies',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => Vocabulary.fromMap(map)).toList();
  }

  // Statistics
  Future<Map<String, int>> getStats() async {
    final vocabs = await getAllVocabularies();

    int speakingCount = 0;
    int writingCount = 0;
    int generalCount = 0;
    int basicCount = 0;
    int advanceCount = 0;

    for (final v in vocabs) {
      if (v.hasUsage('Speaking')) speakingCount++;
      if (v.hasUsage('Writing')) writingCount++;
      if (v.hasUsage('General')) generalCount++;
      if (v.isBasic) basicCount++;
      if (v.isAdvance) advanceCount++;
    }

    return {
      'total': vocabs.length,
      'speaking': speakingCount,
      'writing': writingCount,
      'general': generalCount,
      'basic': basicCount,
      'advance': advanceCount,
    };
  }

  // --- Custom Topics Operations ---

  Future<List<String>> getCustomTopics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_topics',
      orderBy: 'name ASC',
    );
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<void> addCustomTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return;

    final db = await database;
    await db.insert(
      'custom_topics',
      {'name': trimmed},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCustomTopic(String topic) async {
    final db = await database;
    await db.delete(
      'custom_topics',
      where: 'name = ?',
      whereArgs: [topic.trim()],
    );
  }

  // For testing: close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
