import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/vocabulary_card.dart';
import '../vocabulary_detail/vocabulary_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onViewAllTap;

  const HomeScreen({
    super.key,
    required this.onViewAllTap,
  });

  void _navigateToDetail(BuildContext context, Vocabulary vocab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyDetailScreen(vocabulary: vocab),
      ),
    );
  }

  Widget _buildMultiColumnVocabs(
    BuildContext context,
    List<Vocabulary> vocabs, {
    required int columnCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int col = 0; col < columnCount; col++) ...[
          if (col > 0) const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                for (int i = col; i < vocabs.length; i += columnCount)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VocabularyCard(
                      vocabulary: vocabs[i],
                      isHomeStyle: true,
                      onTap: () => _navigateToDetail(context, vocabs[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(vocabularyStatsProvider);
    final recentVocabs = ref.watch(recentVocabulariesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = Responsive.isWide(context);

    final targetTotal = stats.total > 0 ? stats.total : 10;
    final targetDone =
        stats.total > 0 ? (stats.total >= 3 ? 3 : stats.total) : 0;
    final remainingWords = (targetTotal - targetDone).clamp(0, 999);
    final progress =
        targetTotal > 0 ? (targetDone / targetTotal).clamp(0.0, 1.0) : 0.3;
    final progressPercent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lushBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.lushPrimary,
          onRefresh: () async {
            await ref
                .read(vocabularyNotifierProvider.notifier)
                .loadVocabularies();
          },
          child: ResponsiveContentWrapper(
            maxWidth: 1140,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 18,
                vertical: isWide ? 20 : 10,
              ),
              children: [
              // 1. Proportional Header: Logo + "IELTS NOTEBOOK / Kosakata Saya" + Theme Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // App Logo Icon
                        const AppLogo(size: 38),
                        const SizedBox(width: 12),

                        // Title & Subtitle Column (Compact & Balanced Font Size)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1B3326)
                                      : AppColors.lushPrimaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lushPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'IELTS NOTEBOOK',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lushPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Kosakata Saya',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  height: 1.15,
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

                  // Theme Toggle Button (Light / Dark mode)
                  InkWell(
                    onTap: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lushBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : const Color(0x06103A24),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 18,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lushPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Target Review Hari Ini (Green Gradient Banner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x240A6847),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Clock Icon + Title/Subtitle + Badge "3 / 10"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Review Hari Ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$targetDone dari $targetTotal kata selesai',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$targetDone / $targetTotal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6EE7B7)),
                      ),
                    ),
                    const SizedBox(height: 7),

                    // Progress Info: "30% Selesai" & "7 kata lagi"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progressPercent% Selesai',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$remainingWords kata lagi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bottom Row: "⭐ Siap untuk IELTS 7.5+" & "Mulai Review >"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Color(0xFFFFD166), size: 15),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Siap untuk IELTS 7.5+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onViewAllTap,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mulai Review',
                                  style: TextStyle(
                                    color: AppColors.lushPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: AppColors.lushPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 3. IKHTISAR KOSAKATA Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IKHTISAR KOSAKATA',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lushTextMuted,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B3526)
                          : AppColors.lushPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${stats.total} Total',
                      style: TextStyle(
                        fontSize: 10.5,
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

              // Stats Cards (Single Row on Wide Screen, 2x2 Grid on Mobile)
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Kata',
                        count: stats.total,
                        icon: Icons.menu_book_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Speaking',
                        count: stats.speaking,
                        icon: Icons.mic_none_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Writing',
                        count: stats.writing,
                        icon: Icons.mode_edit_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'General',
                        count: stats.general,
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Kata',
                        count: stats.total,
                        icon: Icons.menu_book_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        title: 'Speaking',
                        count: stats.speaking,
                        icon: Icons.mic_none_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Writing',
                        count: stats.writing,
                        icon: Icons.mode_edit_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        title: 'General',
                        count: stats.general,
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // 4. TERBARU DITAMBAHKAN Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TERBARU DITAMBAHKAN',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lushTextMuted,
                    ),
                  ),
                  InkWell(
                    onTap: onViewAllTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Semua',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recently Added Cards
              if (recentVocabs.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lushBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 32,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lushTextMuted,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada kosakata',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketuk tombol + di bawah untuk menambahkan kata pertama Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lushTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isWide)
                _buildMultiColumnVocabs(
                  context,
                  recentVocabs,
                  columnCount: Responsive.isDesktop(context) ? 3 : 2,
                )
              else
                ...recentVocabs.map((vocab) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: VocabularyCard(
                      vocabulary: vocab,
                      isHomeStyle: true,
                      onTap: () => _navigateToDetail(context, vocab),
                    ),
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0x060E7A53),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lushTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3327)
                      : AppColors.lushIconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lushTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
