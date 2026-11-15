import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/vocabulary_model.dart';
import 'database_init.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;
  static Completer<Database>? _initCompleter;
  static String dbName = 'my_vocabulary.db';

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return await _initCompleter!.future;
    }

    _initCompleter = Completer<Database>();
    try {
      final db = await _initDatabase();
      _database = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    await initializePlatformDatabase();

    final String path = await getPlatformDatabasePath(dbName);

    try {
      final db = await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      await _ensureInitialSeeds(db);
      return db;
    } catch (e) {
      debugPrint('Error opening database: $e');
      rethrow;
    }
  }

  Future<void> _ensureInitialSeeds(Database db) async {
    try {
      final res = await db.rawQuery('SELECT COUNT(*) as count FROM vocabularies');
      final count = (res.first['count'] as num?)?.toInt() ?? 0;

      if (count == 0) {
        await _seedInitialData(db);
      }
    } catch (e) {
      debugPrint('Error ensuring initial seeds: $e');
    }
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
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
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
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
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
        createdAt: now.subtract(const Duration(minutes: 15)),
        updatedAt: now.subtract(const Duration(minutes: 15)),
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
        createdAt: now.subtract(const Duration(minutes: 20)),
        updatedAt: now.subtract(const Duration(minutes: 20)),
      ),
      // 15 IELTS Listening Distractors & Paraphrases (Part 2 & Part 3)
      Vocabulary(
        word: 'Free admission',
        meaning: 'Masuk gratis / tanpa biaya masuk',
        level: 'Basic',
        phonetic: '/friː ədˈmɪʃ.ən/',
        definition: "IELTS Paraphrase: 'There is no charge for entry, although donations are welcomed.'",
        example: 'There is free admission to the museum on weekdays.',
        exampleTranslation: 'Masuk museum gratis pada hari kerja biasa.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Local Museum (Part 2). Sering menjebak: kata 'donations' bukan berarti wajib bayar tiket.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 25)),
        updatedAt: now.subtract(const Duration(minutes: 25)),
      ),
      Vocabulary(
        word: 'Created by students',
        meaning: 'Dibuat / dirancang oleh siswa',
        level: 'Basic',
        phonetic: '/kriˈeɪ.tɪd baɪ ˈstjuː.dənts/',
        definition: "IELTS Paraphrase: 'Designed entirely by young people who attended the summer workshop.'",
        example: 'The artwork was created by students from the local college.',
        exampleTranslation: 'Karya seni tersebut dibuat oleh para siswa dari perguruan tinggi setempat.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Art Gallery (Part 2). 'Students' diparafrase menjadi 'young people who attended the course'.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      Vocabulary(
        word: 'Closed on Mondays',
        meaning: 'Tutup pada hari Senin',
        level: 'Basic',
        phonetic: '/kləʊzd ɒn ˈmʌn.deɪz/',
        definition: "IELTS Paraphrase: 'Open every day of the week except at the very start.'",
        example: 'The city library is closed on Mondays for staff maintenance.',
        exampleTranslation: 'Perpustakaan kota tutup pada hari Senin untuk pemeliharaan staf.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: City Library (Part 2). Jebakan 'except at the very start of the week'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 35)),
        updatedAt: now.subtract(const Duration(minutes: 35)),
      ),
      Vocabulary(
        word: 'Mandatory meeting',
        meaning: 'Pertemuan wajib dihadiri',
        level: 'Basic',
        phonetic: '/ˈmæn.də.tər.i ˈmiː.tɪŋ/',
        definition: "IELTS Paraphrase: 'All new members are strictly required to attend.'",
        example: 'Attendance at the orientation session is mandatory for all freshmen.',
        exampleTranslation: 'Kehadiran pada sesi orientasi bersifat wajib bagi semua mahasiswa baru.',
        partOfSpeech: 'noun',
        usageCategories: ['General', 'Speaking'],
        topics: ['IELTS Listening'],
        notes: "Context: Campus Facility (Part 3). Sinonim: mandatory = compulsory = required = obliged to attend.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 40)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
      ),
      Vocabulary(
        word: 'Recently renovated',
        meaning: 'Baru saja direnovasi / diperbarui',
        level: 'Basic',
        phonetic: '/ˈriː.sənt.li ˈren.ə.veɪ.tɪd/',
        definition: "IELTS Paraphrase: 'The interior was fully refurbished and updated only last month.'",
        example: 'The sports centre was recently renovated with modern gym equipment.',
        exampleTranslation: 'Pusat olahraga baru saja direnovasi dengan peralatan gym modern.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Sports Centre (Part 2). 'Renovated' diparafrase menjadi 'refurbished / modernised'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 45)),
        updatedAt: now.subtract(const Duration(minutes: 45)),
      ),
      Vocabulary(
        word: 'Limited parking space',
        meaning: 'Tempat parkir terbatas',
        level: 'Basic',
        phonetic: '/ˈlɪm.ɪ.tɪd ˈpɑː.kɪŋ speɪs/',
        definition: "IELTS Paraphrase: 'There are only a handful of car spots available for visitors.'",
        example: 'Visitors are advised to take public transit due to limited parking space.',
        exampleTranslation: 'Pengunjung disarankan menggunakan angkutan umum karena tempat parkir yang terbatas.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Town Hall (Part 2). 'Limited' diparafrase: 'only a handful of', 'restricted number'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 50)),
        updatedAt: now.subtract(const Duration(minutes: 50)),
      ),
      Vocabulary(
        word: 'Buy tickets in advance',
        meaning: 'Membeli tiket terlebih dahulu / di muka',
        level: 'Basic',
        phonetic: '/baɪ ˈtɪk.ɪts ɪn ədˈvɑːns/',
        definition: "IELTS Paraphrase: 'You need to book your place online ahead of time.'",
        example: 'You should buy tickets in advance to secure a seat for the concert.',
        exampleTranslation: 'Anda sebaiknya membeli tiket di muka untuk mengamankan kursi konser.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Theatre Box Office (Part 2). 'In advance' = 'ahead of time' = 'prior to arrival'.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 55)),
        updatedAt: now.subtract(const Duration(minutes: 55)),
      ),
      Vocabulary(
        word: 'Suitable for beginners',
        meaning: 'Cocok untuk pemula',
        level: 'Basic',
        phonetic: '/ˈsuː.tə.bəl fɔː bɪˈɡɪn.əz/',
        definition: "IELTS Paraphrase: 'Ideal if you have never tried this activity before.'",
        example: 'This yoga class is suitable for beginners of all ages.',
        exampleTranslation: 'Kelas yoga ini cocok untuk pemula dari segala usia.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Community Sports Club (Part 2). Menghadapi opsi jebakan 'for advanced athletes'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 60)),
        updatedAt: now.subtract(const Duration(minutes: 60)),
      ),
      Vocabulary(
        word: 'Reduced price for groups',
        meaning: 'Harga diskon / potongan untuk rombongan',
        level: 'Basic',
        phonetic: '/rɪˈdʒuːst praɪs fɔː ɡruːps/',
        definition: "IELTS Paraphrase: 'Parties of ten or more will receive a special discount.'",
        example: 'The museum offers a reduced price for school groups.',
        exampleTranslation: 'Museum menawarkan potongan harga khusus untuk rombongan sekolah.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Heritage Castle (Part 2). 'Groups' sering diparafrase menjadi 'parties of [x] or more'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 65)),
        updatedAt: now.subtract(const Duration(minutes: 65)),
      ),
      Vocabulary(
        word: 'Postponed until next month',
        meaning: 'Ditunda hingga bulan depan',
        level: 'Basic',
        phonetic: '/pəstˈpəʊnd ənˈtɪl nekst mʌnθ/',
        definition: "IELTS Paraphrase: 'We initially planned to start this week, but it has been put off until December.'",
        example: 'The public lecture has been postponed until next month.',
        exampleTranslation: 'Kuliah umum telah ditunda hingga bulan depan.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: University Lecture Hall (Part 2/3). Distraktor waktu: 'put off / delayed'.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 70)),
        updatedAt: now.subtract(const Duration(minutes: 70)),
      ),
      Vocabulary(
        word: 'Eating is not permitted',
        meaning: 'Dilarang makan dan minum',
        level: 'Basic',
        phonetic: '/ˈiː.tɪŋ ɪz nɒt pəˈmɪt.ɪd/',
        definition: "IELTS Paraphrase: 'Visitors must refrain from consuming snacks or drinks inside.'",
        example: 'Eating is not permitted in the computer lab.',
        exampleTranslation: 'Makan tidak diizinkan di dalam lab komputer.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Science Exhibition (Part 2). 'Not permitted' = 'must refrain from'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 75)),
        updatedAt: now.subtract(const Duration(minutes: 75)),
      ),
      Vocabulary(
        word: 'Located next to reception',
        meaning: 'Terletak di sebelah resepsionis',
        level: 'Basic',
        phonetic: '/ləʊˈkeɪ.tɪd nekst tuː rɪˈsep.ʃən/',
        definition: "IELTS Paraphrase: 'Right beside the main welcome desk as you walk through the doors.'",
        example: 'The cloakroom is located next to the reception counter.',
        exampleTranslation: 'Ruang penitipan barang terletak di sebelah meja resepsionis.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Campus Information Desk (Part 2 Map). 'Next to' = 'adjacent to' = 'right beside'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 80)),
        updatedAt: now.subtract(const Duration(minutes: 80)),
      ),
      Vocabulary(
        word: 'Bring your own equipment',
        meaning: 'Membawa peralatan sendiri',
        level: 'Basic',
        phonetic: '/brɪŋ jɔːr əʊn ɪˈkwɪp.mənt/',
        definition: "IELTS Paraphrase: 'Participants are expected to supply their own sports gear.'",
        example: 'You are required to bring your own equipment to the tennis workshop.',
        exampleTranslation: 'Anda diwajibkan membawa peralatan sendiri ke lokakarya tenis.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: Recreation Centre (Part 2). 'Supply own gear'.",
        isFavorite: false,
        createdAt: now.subtract(const Duration(minutes: 85)),
        updatedAt: now.subtract(const Duration(minutes: 85)),
      ),
      Vocabulary(
        word: 'Change of topic',
        meaning: 'Perubahan topik tugas / penelitian',
        level: 'Basic',
        phonetic: '/tʃeɪndʒ ɒv ˈtɒp.ɪk/',
        definition: "IELTS Paraphrase: 'We initially chose solar power, but we decided to switch to plastic recycling.'",
        example: 'The tutor approved our change of topic for the final presentation.',
        exampleTranslation: 'Dosen pembimbing menyetujui perubahan topik kami untuk presentasi akhir.',
        partOfSpeech: 'noun',
        usageCategories: ['General', 'Speaking'],
        topics: ['IELTS Listening'],
        notes: "Context: Tutor Consultation (Part 3). Pola diskusi: ide awal disebut lalu sepakat berubah.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 90)),
        updatedAt: now.subtract(const Duration(minutes: 90)),
      ),
      Vocabulary(
        word: 'Available on weekdays only',
        meaning: 'Hanya tersedia pada hari kerja',
        level: 'Basic',
        phonetic: '/əˈveɪ.lə.bəl ɒn ˈwiːk.deɪz ˈəʊn.li/',
        definition: "IELTS Paraphrase: 'The campus shuttle operates Monday through Friday, not over the weekend.'",
        example: 'The library reference room is available on weekdays only.',
        exampleTranslation: 'Ruang referensi perpustakaan hanya tersedia pada hari kerja.',
        partOfSpeech: 'phrase',
        usageCategories: ['General'],
        topics: ['IELTS Listening'],
        notes: "Context: University Facility (Part 2). 'Monday through Friday, not over the weekend'.",
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 95)),
        updatedAt: now.subtract(const Duration(minutes: 95)),
      ),
    ];

    final existingRows = await db.query('vocabularies', columns: ['word']);
    final existingWords = {
      for (final row in existingRows)
        (row['word'] as String).trim().toLowerCase()
    };

    for (final vocab in starterVocabularies) {
      if (!existingWords.contains(vocab.word.trim().toLowerCase())) {
        await db.insert('vocabularies', vocab.toMap());
        existingWords.add(vocab.word.trim().toLowerCase());
      }
    }

    final initialTopics = [
      'Task 2',
      'Part 1-3',
      'Environment',
      'Technology',
      'Health',
      'Education',
      'Society',
      'IELTS Listening',
      'Distractors & Traps',
    ];
    for (final topic in initialTopics) {
      await db.insert(
        'custom_topics',
        {'name': topic},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
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
    _initCompleter = null;
  }
}
