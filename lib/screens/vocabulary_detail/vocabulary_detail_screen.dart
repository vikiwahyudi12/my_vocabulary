import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/badges.dart';
import '../vocabulary_form/vocabulary_form_screen.dart';

class VocabularyDetailScreen extends ConsumerWidget {
  final Vocabulary vocabulary;

  const VocabularyDetailScreen({
    super.key,
    required this.vocabulary,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Hapus Kosakata?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${vocabulary.word}"? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lushTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && vocabulary.id != null) {
      await ref.read(vocabularyNotifierProvider.notifier).deleteVocabulary(vocabulary.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.lushPrimary,
            content: Text('Berhasil menghapus "${vocabulary.word}"'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToEdit(BuildContext context, Vocabulary vocab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyFormScreen(vocabularyToEdit: vocab),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch live state in case this item was updated
    final allVocabs = ref.watch(filteredVocabulariesProvider);
    final current = allVocabs.firstWhere(
      (v) => v.id == vocabulary.id,
      orElse: () => vocabulary,
    );

    final primaryUsage = current.usageCategories.isNotEmpty
        ? current.usageCategories.first
        : 'General';
    final primaryTopic = current.topics.isNotEmpty ? current.topics.first : '';
    final usageTopicLabel = primaryTopic.isNotEmpty
        ? '$primaryUsage $primaryTopic'
        : primaryUsage;
    final bandLabel = current.isAdvance ? 'Band 7.0+' : 'Band 5.5+';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lushBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
                  width: 1,
                ),
              ),
              child: BackButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                ),
                color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          'Detail Kosakata',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Favorite Toggle Button (Circular Container)
          if (current.id != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  ref
                      .read(vocabularyNotifierProvider.notifier)
                      .toggleFavorite(current.id!, current.isFavorite);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    current.isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 19,
                    color: current.isFavorite
                        ? (isDark ? AppColors.darkPrimary : AppColors.lushPrimary)
                        : (isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted),
                  ),
                ),
              ),
            ),

          // Edit Button (Circular Container)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _navigateToEdit(context, current),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
                ),
              ),
            ),
          ),

          // Delete Button (Circular Container)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => _confirmDelete(context, ref),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E1919) : const Color(0xFFFDEDED),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF4C2727) : const Color(0xFFFFCDD2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 780,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. HERO WORD CARD (Elevated White Card with Lush Green details)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : const Color(0x0A0E7A53),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Word + Part of Speech + Level Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          current.word,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lushTextPrimary,
                          ),
                        ),
                      ),
                      if (current.partOfSpeech != null &&
                          current.partOfSpeech!.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        PartOfSpeechBadge(
                          partOfSpeech: current.partOfSpeech!,
                          isSmall: true,
                        ),
                      ],
                      const SizedBox(width: 6),
                      LevelBadge(
                        level: current.level,
                        isSmall: true,
                      ),
                    ],
                  ),

                  // Row 2: Phonetic Transcription + Pronunciation Audio Button
                  if (current.phonetic != null &&
                      current.phonetic!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          current.phonetic!,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lushPhonetic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pelafalan: "${current.word}"'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3528)
                                  : AppColors.lushIconCircle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volume_up_rounded,
                              size: 15,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lushPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  Divider(
                    color: isDark ? AppColors.darkDivider : AppColors.lushDivider,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 14),

                  // Indonesian Meaning Section
                  Text(
                    'ARTI BAHASA INDONESIA',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current.meaning,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFD5E3DB) : const Color(0xFF26362D),
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Tags Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF22352B) : const Color(0xFFF1F5F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          usageTopicLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA6BAAF) : const Color(0xFF4A5C52),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B3526) : AppColors.lushPrimaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bandLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B3526) : AppColors.lushPrimaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Siap Latihan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. CONTOH KALIMAT CARD (if present)
            if (current.example != null && current.example!.trim().isNotEmpty) ...[
              _buildDetailSectionCard(
                isDark: isDark,
                title: 'CONTOH KALIMAT',
                icon: Icons.format_quote_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${current.example!}”',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lushTextPrimary,
                      ),
                    ),
                    if (current.exampleTranslation != null &&
                        current.exampleTranslation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2A21) : AppColors.lushPrimaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          current.exampleTranslation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lushTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. DEFINISI CARD (if present)
            if (current.definition != null && current.definition!.trim().isNotEmpty) ...[
              _buildDetailSectionCard(
                isDark: isDark,
                title: 'DEFINISI BAHASA INGGRIS',
                icon: Icons.menu_book_outlined,
                child: Text(
                  current.definition!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 4. CATATAN & TIPS IELTS CARD (if present)
            if (current.notes != null && current.notes!.trim().isNotEmpty) ...[
              _buildDetailSectionCard(
                isDark: isDark,
                title: 'CATATAN & TIPS IELTS',
                icon: Icons.lightbulb_outline_rounded,
                iconColor: const Color(0xFFF59E0B),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262013) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF4C3E1F) : const Color(0xFFFDE68A),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    current.notes!,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 5. SEMUA KATEGORI & TOPIK
            _buildDetailSectionCard(
              isDark: isDark,
              title: 'SEMUA KATEGORI & TOPIK',
              icon: Icons.category_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...current.usageCategories.map((u) => UsageBadge(usage: u)),
                  ...current.topics.map((t) => TopicBadge(topic: t)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Footer: Date added
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Ditambahkan ${DateFormat('d MMMM yyyy • HH:mm').format(current.createdAt)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDetailSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    Color? iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: iconColor ??
                    (isDark ? AppColors.darkPrimary : AppColors.lushPrimary),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color:
                      isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
