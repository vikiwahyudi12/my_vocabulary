import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/vocabulary_card.dart';
import '../vocabulary_detail/vocabulary_detail_screen.dart';
import '../vocabulary_form/vocabulary_form_screen.dart';

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(vocabularyFilterProvider).query;
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, Vocabulary vocab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyDetailScreen(vocabulary: vocab),
      ),
    );
  }

  void _openAddVocabulary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VocabularyFormScreen(),
      ),
    );
  }

  Widget _buildMultiColumnList(
    BuildContext context,
    List<Vocabulary> list, {
    required int columnCount,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 84,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int col = 0; col < columnCount; col++) ...[
            if (col > 0) const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  for (int i = col; i < list.length; i += columnCount)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: VocabularyCard(
                        vocabulary: list[i],
                        onTap: () => _navigateToDetail(context, list[i]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTopicFilterBottomSheet() {
    final allTopics = ref.read(allTopicsProvider);
    final currentTopic = ref.read(vocabularyFilterProvider).selectedTopic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkDivider : AppColors.lushDivider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Filter berdasarkan Topik',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Semua Topik'),
                      selected: currentTopic == null,
                      onSelected: (_) {
                        ref.read(vocabularyFilterProvider.notifier).setTopic(null);
                        Navigator.pop(ctx);
                      },
                    ),
                    ...allTopics.map((topic) {
                      final isSelected = currentTopic == topic;
                      return FilterChip(
                        label: Text(topic),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref
                              .read(vocabularyFilterProvider.notifier)
                              .setTopic(selected ? topic : null);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(vocabularyFilterProvider);
    final filteredList = ref.watch(filteredVocabulariesProvider);
    final stats = ref.watch(vocabularyStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lushBackground,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          maxWidth: 1140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Top Section: Logo + "● X KATA TERSIMPAN / Kosakata" + Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 34),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pill: "● X KATA TERSIMPAN"
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
                                  '${stats.total} KATA TERSIMPAN',
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
                            'Kosakata',
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
                    ],
                  ),

                  // Action Buttons: (+) & (☰)
                  Row(
                    children: [
                      // (+) Add Button
                      InkWell(
                        onTap: _openAddVocabulary,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3528)
                                : AppColors.lushIconCircle,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lushBorder,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 19,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Menu / Filter Button (☰)
                      InkWell(
                        onTap: _showTopicFilterBottomSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3528)
                                : AppColors.lushIconCircle,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lushBorder,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            size: 19,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar ("Cari kata, arti, atau contoh...")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(vocabularyFilterProvider.notifier).setQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kata, arti, atau contoh...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lushTextMuted,
                      fontSize: 14,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(vocabularyFilterProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.mic_none_rounded,
                              size: 19,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lushTextMuted,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Pills (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterPill(
                    label: 'Semua',
                    isSelected: filter.selectedUsage == null &&
                        filter.selectedLevel == null &&
                        !filter.onlyFavorites,
                    onTap: () {
                      ref.read(vocabularyFilterProvider.notifier).reset();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Speaking',
                    isSelected: filter.selectedUsage == 'Speaking',
                    onTap: () {
                      ref.read(vocabularyFilterProvider.notifier).setUsage(
                            filter.selectedUsage == 'Speaking' ? null : 'Speaking',
                          );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Writing',
                    isSelected: filter.selectedUsage == 'Writing',
                    onTap: () {
                      ref.read(vocabularyFilterProvider.notifier).setUsage(
                            filter.selectedUsage == 'Writing' ? null : 'Writing',
                          );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Favorit',
                    isSelected: filter.onlyFavorites,
                    icon: Icons.bookmark_rounded,
                    onTap: () {
                      ref
                          .read(vocabularyFilterProvider.notifier)
                          .toggleOnlyFavorites();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Advance',
                    isSelected: filter.selectedLevel == 'Advance',
                    onTap: () {
                      ref.read(vocabularyFilterProvider.notifier).setLevel(
                            filter.selectedLevel == 'Advance' ? null : 'Advance',
                          );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Basic',
                    isSelected: filter.selectedLevel == 'Basic',
                    onTap: () {
                      ref.read(vocabularyFilterProvider.notifier).setLevel(
                            filter.selectedLevel == 'Basic' ? null : 'Basic',
                          );
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sub-header Row: "● Daftar Kata" (left) and "Terbaru ⇅" (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Daftar Kata',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lushTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Sort Toggle Pill: "Terbaru ⇅"
                  InkWell(
                    onTap: () {
                      final newSort = filter.sort == VocabularySort.newest
                          ? VocabularySort.alphabetical
                          : VocabularySort.newest;
                      ref
                          .read(vocabularyFilterProvider.notifier)
                          .setSort(newSort);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3528)
                            : AppColors.lushPrimaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.sort == VocabularySort.newest
                                ? 'Terbaru'
                                : 'A-Z',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lushPrimary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.swap_vert_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Vocabulary List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lushTextMuted,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Kosakata tidak ditemukan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coba ubah kata kunci pencarian atau filter Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lushTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lushPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(vocabularyFilterProvider.notifier)
                                    .reset();
                              },
                              child: const Text('Reset Filter'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : isWide
                      ? _buildMultiColumnList(
                          context,
                          filteredList,
                          columnCount: Responsive.isDesktop(context) ? 3 : 2,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 84,
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final vocab = filteredList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: VocabularyCard(
                                vocabulary: vocab,
                                onTap: () => _navigateToDetail(context, vocab),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.lushPrimary)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lushBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.darkPrimary
                            : AppColors.lushPrimary)
                        .withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12.5,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lushTextSecondary),
              ),
              const SizedBox(width: 3.5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lushTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
