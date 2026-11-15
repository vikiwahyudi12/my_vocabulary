import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/vocabulary_card.dart';
import '../vocabulary_detail/vocabulary_detail_screen.dart';

class TopicMeta {
  final String key;
  final String titleId;
  final String titleEn;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> sampleKeywords;

  const TopicMeta({
    required this.key,
    required this.titleId,
    required this.titleEn,
    required this.description,
    required this.icon,
    required this.color,
    required this.sampleKeywords,
  });
}

const List<TopicMeta> kCuratedTopics = [
  TopicMeta(
    key: 'Daily Objects',
    titleId: 'Objek & Rumah',
    titleEn: 'Daily Objects & House',
    description: 'Benda sehari-hari: kursi, meja, laci, tirai, keran, pipa, peralatan rumah tangga (Listening Part 1 & Speaking)',
    icon: Icons.chair_rounded,
    color: Color(0xFF0E7A53),
    sampleKeywords: ['Chair', 'Armchair', 'Drawer', 'Curtain', 'Tap', 'Appliance', 'Cutlery'],
  ),
  TopicMeta(
    key: 'Animals & Wildlife',
    titleId: 'Daftar Hewan & Satwa',
    titleEn: 'Animals & Wildlife',
    description: 'Daftar nama hewan lengkap: kelelawar (bat), tikus (mouse/rat), burung hantu (owl), elang, pinguin, lumba-lumba, paus, singa, gajah, serta ciri fisik (sayap, paruh, cakar, bulu, sisik)',
    icon: Icons.pets_rounded,
    color: Color(0xFFD97706),
    sampleKeywords: ['Bat', 'Mouse', 'Rat', 'Owl', 'Eagle', 'Penguin', 'Dolphin', 'Whale', 'Wing', 'Beak', 'Claw', 'Fur'],
  ),
  TopicMeta(
    key: 'Fruits & Vegetables',
    titleId: 'Buah & Sayuran',
    titleEn: 'Fruits & Vegetables',
    description: 'Daftar buah & sayur esensial: mangga (mango), lemon, jeruk nipis (lime), nanas, semangka, pisang, apel, alpukat, tomat, kentang, bawang putih, wortel, bayam',
    icon: Icons.eco_rounded,
    color: Color(0xFF16A34A),
    sampleKeywords: ['Mango', 'Lemon', 'Lime', 'Pineapple', 'Watermelon', 'Avocado', 'Garlic', 'Carrot', 'Tomato'],
  ),
  TopicMeta(
    key: 'Food & Taste',
    titleId: 'Makanan, Rasa & Tekstur',
    titleEn: 'Food, Taste & Texture',
    description: 'Deskripsi kuliner & tekstur: renyah, lembut, gurih, hambar, basi, asam, pahit, kenyal, empuk, nutrisi',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFEA580C),
    sampleKeywords: ['Crispy', 'Crunchy', 'Tender', 'Fluffy', 'Savoury', 'Bland', 'Stale', 'Nutrient'],
  ),
  TopicMeta(
    key: 'Nature & Forestry',
    titleId: 'Hutan & Alam',
    titleEn: 'Forestry & Flora',
    description: 'Hutan, tajuk daun (canopy), dedaunan, batang pohon, kayu olahan, semak belukar, keanekaragaman hayati',
    icon: Icons.forest_rounded,
    color: Color(0xFF059669),
    sampleKeywords: ['Forest', 'Canopy', 'Foliage', 'Woodland', 'Timber', 'Trunk', 'Biodiversity'],
  ),
  TopicMeta(
    key: 'Weather & Climate',
    titleId: 'Cuaca, Iklim & Udara',
    titleEn: 'Weather & Climate',
    description: 'Air, angin sepoi, hembusan kencang, badai, kelembapan udara, kekeringan, hujan lebat, kabut asap',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFF0284C7),
    sampleKeywords: ['Water', 'Breeze', 'Gust', 'Drizzle', 'Drought', 'Humidity', 'Precipitation'],
  ),
  TopicMeta(
    key: 'Education',
    titleId: 'Pendidikan & Kampus',
    titleEn: 'Education & Academics',
    description: 'Kurikulum, biaya kuliah (tuition), beasiswa, kuliah umum, tutorial, asrama, tugas akhir & disertasi',
    icon: Icons.school_rounded,
    color: Color(0xFF4F46E5),
    sampleKeywords: ['Curriculum', 'Tuition', 'Scholarship', 'Lecture', 'Tutorial', 'Dissertation'],
  ),
  TopicMeta(
    key: 'Society',
    titleId: 'Masyarakat & Sosial',
    titleEn: 'Society & Community',
    description: 'Warga negara, demografi penduduk, urbanisasi perkotaan, bantuan sosial, kesenjangan sosial, sukarelawan',
    icon: Icons.groups_rounded,
    color: Color(0xFF7C3AED),
    sampleKeywords: ['Community', 'Citizen', 'Demographic', 'Urbanization', 'Welfare', 'Inequality'],
  ),
  TopicMeta(
    key: 'Health',
    titleId: 'Kesehatan & Nutrisi',
    titleEn: 'Health & Wellbeing',
    description: 'Gejala penyakit, diagnosis, resep obat dokter, perawatan medis, kekebalan tubuh, gaya hidup pasif',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE11D48),
    sampleKeywords: ['Symptom', 'Diagnosis', 'Prescription', 'Treatment', 'Immunity', 'Sedentary'],
  ),
  TopicMeta(
    key: 'Travel & Transport',
    titleId: 'Perjalanan & Transportasi',
    titleEn: 'Travel & Tourism',
    description: 'Rencana perjalanan (itinerary), perjalanan komuter, tiket, tarif ongkos, terminal stasiun, kemacetan jalan',
    icon: Icons.flight_takeoff_rounded,
    color: Color(0xFF2563EB),
    sampleKeywords: ['Itinerary', 'Commute', 'Destination', 'Fare', 'Congestion', 'Baggage'],
  ),
  TopicMeta(
    key: 'Places & Town',
    titleId: 'Tempat & Fasilitas Kota',
    titleEn: 'Places, Buildings & Town',
    description: 'Fasilitas umum: apotek (pharmacy), toko roti (bakery), perpustakaan, bundaran (roundabout), zebra cross, trotoar, jembatan, kantin, balai kota, kastel',
    icon: Icons.location_city_rounded,
    color: Color(0xFF0369A1),
    sampleKeywords: ['Pharmacy', 'Bakery', 'Library', 'Roundabout', 'Pedestrian crossing', 'Bridge', 'Canteen', 'Town hall'],
  ),
  TopicMeta(
    key: 'Clothing & Accessories',
    titleId: 'Pakaian & Aksesoris',
    titleEn: 'Clothing & Accessories',
    description: 'Pakaian & perlengkapan pribadi: jaket, mantel (coat), syal (scarf), sarung tangan (gloves), sepatu bot, ransel, koper, kacamata, ikat pinggang',
    icon: Icons.checkroom_rounded,
    color: Color(0xFFC026D3),
    sampleKeywords: ['Jacket', 'Coat', 'Scarf', 'Gloves', 'Boots', 'Backpack', 'Suitcase', 'Glasses'],
  ),
  TopicMeta(
    key: 'Shapes & Measurement',
    titleId: 'Bentuk & Pengukuran',
    titleEn: 'Shapes & Measurement',
    description: 'Bentuk geometris & dimensi deskriptif: melingkar (circular), persegi panjang (rectangular), segitiga, dangkal (shallow), dalam (deep), curam (steep)',
    icon: Icons.square_foot_rounded,
    color: Color(0xFF0D9488),
    sampleKeywords: ['Circular', 'Rectangular', 'Triangular', 'Shallow', 'Deep', 'Steep'],
  ),
  TopicMeta(
    key: 'Work & Career',
    titleId: 'Pekerjaan & Karir',
    titleEn: 'Work & Employment',
    description: 'Profesi, rekan kerja, kenaikan jabatan, surat pengunduran diri, kerja lembur, jaminan pensiun, tenaga kerja',
    icon: Icons.work_rounded,
    color: Color(0xFF475569),
    sampleKeywords: ['Occupation', 'Colleague', 'Promotion', 'Resignation', 'Overtime', 'Workforce'],
  ),
  TopicMeta(
    key: 'Technology',
    titleId: 'Teknologi & Inovasi',
    titleEn: 'Technology & Science',
    description: 'Perangkat pintar, otomatisasi industri, kecerdasan buatan, koneksi nirkabel, terobosan inovasi baru',
    icon: Icons.memory_rounded,
    color: Color(0xFF0891B2),
    sampleKeywords: ['Automated', 'Device', 'Breakthrough', 'Wireless', 'Artificial intelligence'],
  ),
  TopicMeta(
    key: 'Task 2',
    titleId: 'Esai Akademik (Task 2)',
    titleEn: 'Academic Essay Writing',
    description: 'Koleksi frasa argumen formal, kata penghubung transisi, dan kosakata esai Band 7.5+',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF0E7A53),
    sampleKeywords: ['Mitigate', 'Ubiquitous', 'Conceivable', 'Exacerbate', 'Substantiate'],
  ),
  TopicMeta(
    key: 'Part 1-3',
    titleId: 'Kelancaran Speaking (Part 1-3)',
    titleEn: 'Speaking Fluency & Idioms',
    description: 'Idiom alami, kolokasi kaya, dan frasa ekspresif untuk meningkatkan band fluency dan leksikal',
    icon: Icons.record_voice_over_rounded,
    color: Color(0xFF9333EA),
    sampleKeywords: ['In a nutshell', 'Once in a blue moon', 'Piece of cake', 'Cost an arm and a leg'],
  ),
  TopicMeta(
    key: 'IELTS Listening',
    titleId: 'Jebakan Audio Listening',
    titleEn: 'Distractors & Traps',
    description: 'Kata kunci jebakan (distractors), perubahan rencana mendadak, dan parafrase jawaban ujian resmi',
    icon: Icons.headphones_rounded,
    color: Color(0xFFD97706),
    sampleKeywords: ['Initially', 'Postpone', 'Alternative', 'Exceed', 'Approximately'],
  ),
];

class TopicExplorerScreen extends ConsumerStatefulWidget {
  final void Function(String topic)? onSelectTopic;

  const TopicExplorerScreen({
    super.key,
    this.onSelectTopic,
  });

  @override
  ConsumerState<TopicExplorerScreen> createState() =>
      _TopicExplorerScreenState();
}

class _TopicExplorerScreenState extends ConsumerState<TopicExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'All'; // 'All', 'Basic', 'Advance'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTopicDetail(BuildContext context, String topicKey, String topicTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TopicDetailSheet(
        topicKey: topicKey,
        topicTitle: topicTitle,
        onViewInFullList: widget.onSelectTopic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = Responsive.isWide(context);
    final allVocabs = ref.watch(vocabularyNotifierProvider).value ?? [];

    // Compute counts per topic
    final Map<String, List<Vocabulary>> topicMap = {};
    int totalBasic = 0;
    int totalAdvance = 0;

    for (final v in allVocabs) {
      if (v.isBasic) totalBasic++;
      if (v.isAdvance) totalAdvance++;

      for (final t in v.topics) {
        topicMap.putIfAbsent(t, () => []).add(v);
      }
    }

    final query = _searchController.text.trim().toLowerCase();

    // Filter curated topics
    final filteredTopics = kCuratedTopics.where((meta) {
      final matchesQuery = query.isEmpty ||
          meta.titleId.toLowerCase().contains(query) ||
          meta.titleEn.toLowerCase().contains(query) ||
          meta.description.toLowerCase().contains(query) ||
          meta.sampleKeywords.any((k) => k.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      if (_selectedLevel == 'All') return true;

      final wordsInTopic = topicMap[meta.key] ?? [];
      if (_selectedLevel == 'Basic') {
        return wordsInTopic.any((w) => w.isBasic);
      } else if (_selectedLevel == 'Advance') {
        return wordsInTopic.any((w) => w.isAdvance);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lushBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Title
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1B3326)
                                  : AppColors.lushPrimaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lushPrimary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'TOPIK KOSAKATA IELTS',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lushPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lushBorder,
                            ),
                          ),
                          child: Text(
                            '${allVocabs.length} Kosakata',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lushTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Jelajahi per Topik & Kategori',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lushTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kuasai kosakata dari dasar (kursi, air, hewan, tekstur makanan) hingga lanjutan untuk Listening, Speaking, dan Writing.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lushTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Stats Row
                    Row(
                      children: [
                        _buildQuickStatCard(
                          title: 'Total Topik',
                          value: '${kCuratedTopics.length}',
                          icon: Icons.grid_view_rounded,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildQuickStatCard(
                          title: 'Kata Dasar (Basic)',
                          value: '$totalBasic',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF0284C7),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildQuickStatCard(
                          title: 'Lanjutan (Advance)',
                          value: '$totalAdvance',
                          icon: Icons.stars_rounded,
                          color: const Color(0xFFD97706),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lushBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari topik atau kata (contoh: kursi, hewan, renyah, forest)...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lushTextMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Level Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'Level:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lushTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLevelPill('All', 'Semua Level', isDark),
                          const SizedBox(width: 6),
                          _buildLevelPill('Basic', 'Dasar (A1 - B1)', isDark),
                          const SizedBox(width: 6),
                          _buildLevelPill('Advance', 'Lanjutan (B2 - C1)', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grid / List of Topics
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              sliver: isWide
                  ? SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 460,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 265,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final meta = filteredTopics[index];
                          final words = topicMap[meta.key] ?? [];
                          return _buildTopicCard(meta, words, isDark);
                        },
                        childCount: filteredTopics.length,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final meta = filteredTopics[index];
                          final words = topicMap[meta.key] ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTopicCard(meta, words, isDark),
                          );
                        },
                        childCount: filteredTopics.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lushTextMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lushTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelPill(String key, String label, bool isDark) {
    final isSelected = _selectedLevel == key;
    return InkWell(
      onTap: () => setState(() => _selectedLevel = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.lushPrimary)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lushBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lushTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(
      TopicMeta meta, List<Vocabulary> wordsInTopic, bool isDark) {
    final basicCount = wordsInTopic.where((w) => w.isBasic).length;
    final advanceCount = wordsInTopic.where((w) => w.isAdvance).length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openTopicDetail(context, meta.key, meta.titleId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Title + Count Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(meta.icon, size: 24, color: meta.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.titleId,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lushTextPrimary,
                            ),
                          ),
                          Text(
                            meta.titleEn,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: meta.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B3326)
                            : AppColors.lushPrimaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${wordsInTopic.length} Kata',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  meta.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lushTextSecondary,
                  ),
                ),

                const SizedBox(height: 14),

                // Level breakdown + Sample Pills
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$basicCount Dasar • $advanceCount Lanjutan',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Buka Topik ›',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lushPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sample Word Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final kw in meta.sampleKeywords.take(4))
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lushBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lushBorder,
                              ),
                            ),
                            child: Text(
                              kw,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lushTextPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Sheet showing all words inside the selected topic
class _TopicDetailSheet extends ConsumerStatefulWidget {
  final String topicKey;
  final String topicTitle;
  final void Function(String topic)? onViewInFullList;

  const _TopicDetailSheet({
    required this.topicKey,
    required this.topicTitle,
    this.onViewInFullList,
  });

  @override
  ConsumerState<_TopicDetailSheet> createState() => _TopicDetailSheetState();
}

class _TopicDetailSheetState extends ConsumerState<_TopicDetailSheet> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allVocabs = ref.watch(vocabularyNotifierProvider).value ?? [];

    final topicWords = allVocabs.where((v) {
      return v.topics.any((t) => t.toLowerCase() == widget.topicKey.toLowerCase());
    }).toList();

    final q = _queryController.text.trim().toLowerCase();
    final filtered = topicWords.where((v) {
      if (q.isEmpty) return true;
      return v.word.toLowerCase().contains(q) ||
          v.meaning.toLowerCase().contains(q) ||
          (v.definition?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topicTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lushTextPrimary,
                        ),
                      ),
                      Text(
                        '${topicWords.length} Kosakata Terkait Topik Ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lushTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onViewInFullList != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lushPrimary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onViewInFullList!(widget.topicKey);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text(
                      'Buka di Daftar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),

          // Search Field inside Sheet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lushBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _queryController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari kata di topik ini...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  suffixIcon: _queryController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _queryController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),

          const Divider(height: 16),

          // List of Words
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada kata yang sesuai.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lushTextMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final vocab = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VocabularyCard(
                          vocabulary: vocab,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VocabularyDetailScreen(
                                  vocabulary: vocab,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
