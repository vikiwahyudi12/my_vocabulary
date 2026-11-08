import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../models/vocabulary_model.dart';
import '../providers/vocabulary_provider.dart';
import 'badges.dart';

class VocabularyCard extends ConsumerWidget {
  final Vocabulary vocabulary;
  final VoidCallback onTap;
  final bool isHomeStyle;

  const VocabularyCard({
    super.key,
    required this.vocabulary,
    required this.onTap,
    this.isHomeStyle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format primary usage & topic tag (e.g. "Speaking Part 3" or "Writing Task 2")
    final primaryUsage = vocabulary.usageCategories.isNotEmpty
        ? vocabulary.usageCategories.first
        : 'General';
    final primaryTopic =
        vocabulary.topics.isNotEmpty ? vocabulary.topics.first : '';
    final usageTopicLabel = primaryTopic.isNotEmpty
        ? '$primaryUsage $primaryTopic'
        : primaryUsage;

    // Band score recommendation
    final bandLabel = vocabulary.isAdvance ? 'Band 7.0+' : 'Band 5.5+';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0x06103A24),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Word + Part of Speech + Bookmark (or Audio button for Home)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              vocabulary.word,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lushTextPrimary,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vocabulary.partOfSpeech != null &&
                              vocabulary.partOfSpeech!.trim().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            PartOfSpeechBadge(
                              partOfSpeech: vocabulary.partOfSpeech!,
                              isSmall: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (isHomeStyle)
                      // Speaker button for Home card style
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pelafalan: "${vocabulary.word}"'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3327)
                                : AppColors.lushIconCircle,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ),
                      )
                    else
                      // Bookmark button for Kosakata list style
                      if (vocabulary.id != null)
                        InkWell(
                          onTap: () {
                            ref
                                .read(vocabularyNotifierProvider.notifier)
                                .toggleFavorite(
                                  vocabulary.id!,
                                  vocabulary.isFavorite,
                                );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              vocabulary.isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 22,
                              color: vocabulary.isFavorite
                                  ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.bookmarkActive)
                                  : (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.bookmarkInactive),
                            ),
                          ),
                        ),
                  ],
                ),

                // Row 2: Phonetics + inline speaker icon
                if (vocabulary.phonetic != null &&
                    vocabulary.phonetic!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        vocabulary.phonetic!,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushPhonetic,
                        ),
                      ),
                      if (!isHomeStyle) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pelafalan: "${vocabulary.word}"'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // Row 3: Indonesian Meaning
                Text(
                  vocabulary.meaning,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFD5E3DB)
                        : const Color(0xFF26362D),
                    letterSpacing: -0.2,
                  ),
                ),

                // Row 4: Definition or Example quote in italics
                if (vocabulary.example != null &&
                    vocabulary.example!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${vocabulary.example!}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lushTextSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (vocabulary.definition != null &&
                    vocabulary.definition!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${vocabulary.definition!}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lushTextSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 14),

                // Row 5: Footer Tags & Status
                if (isHomeStyle)
                  // Home card style: "Speaking  •  Part 1-3" + chevron >
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            primaryUsage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lushPrimary,
                            ),
                          ),
                          if (primaryTopic.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lushTextMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              primaryTopic,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lushTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lushTextMuted,
                      ),
                    ],
                  )
                else
                  // Kosakata list style: [Speaking Part 3] [Band 7.0+] [✓ Siap Latihan]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Pill 1: e.g. "Speaking Part 3"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF22352B)
                                    : const Color(0xFFF1F5F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                usageTopicLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFA6BAAF)
                                      : const Color(0xFF4A5C52),
                                ),
                              ),
                            ),

                            // Pill 2: e.g. "Band 7.0+"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1B3526)
                                    : AppColors.lushPrimaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bandLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lushPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Status Tag: "✓ Siap Latihan" or "● Mastered"
                      if (vocabulary.isFavorite)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Mastered',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lushPrimary,
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1B3526)
                                : AppColors.lushPrimaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF264C37)
                                  : AppColors.lushPrimaryBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lushPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Siap Latihan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lushPrimary,
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
        ),
      ),
    );
  }
}
