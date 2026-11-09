import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/responsive/responsive_layout.dart';
import '../core/services/export_service.dart';
import '../providers/theme_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/cloud_sync_modal.dart';
import '../providers/cloud_sync_provider.dart';
import 'home/home_screen.dart';
import 'vocabulary_form/vocabulary_form_screen.dart';
import 'vocabulary_list/vocabulary_list_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _selectFavoritesTab() {
    ref.read(vocabularyFilterProvider.notifier).setOnlyFavorites(true);
    setState(() {
      _currentIndex = 1;
    });
  }

  void _openAddVocabulary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VocabularyFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = Responsive.isWide(context);

    final pages = [
      HomeScreen(onViewAllTap: () => _onTabSelected(1)),
      const VocabularyListScreen(),
    ];

    if (isWide) {
      // ═══════════════════════════════════════════════════════════════════════
      // WEB / DESKTOP / TABLET ADAPTIVE LAYOUT (Sidebar + Main Content Area)
      // ═══════════════════════════════════════════════════════════════════════
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lushBackground,
        body: Row(
          children: [
            // Left Sidebar
            _buildWebSidebar(isDark),

            // Vertical divider line
            Container(
              width: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lushBorder,
            ),

            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MOBILE LAYOUT (Classic Bottom Bar with Center Docked FAB)
    // ═══════════════════════════════════════════════════════════════════════
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkPrimary : AppColors.lushPrimary)
                  .withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddVocabulary,
          tooltip: 'Tambah Kosakata',
          backgroundColor:
              isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 10,
        shadowColor: const Color(0x1A0E7A53),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Beranda Tab
            Expanded(
              child: InkWell(
                onTap: () => _onTabSelected(0),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color: _currentIndex == 0
                          ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary)
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted),
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Beranda',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _currentIndex == 0
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _currentIndex == 0
                            ? (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary)
                            : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lushTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gap for Centered Floating Action Button
            const SizedBox(width: 52),

            // Kosakata Tab
            Expanded(
              child: InkWell(
                onTap: () => _onTabSelected(1),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentIndex == 1
                          ? Icons.menu_book_rounded
                          : Icons.menu_book_outlined,
                      color: _currentIndex == 1
                          ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary)
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted),
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Kosakata',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _currentIndex == 1
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _currentIndex == 1
                            ? (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary)
                            : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lushTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a responsive sidebar for wide screens (web / desktop)
  Widget _buildWebSidebar(bool isDark) {
    final themeMode = ref.watch(themeModeProvider);
    final stats = ref.watch(vocabularyStatsProvider);

    return Container(
      width: 260,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo & Branding
                    Row(
                      children: [
                        const AppLogo(size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1B3326)
                                      : AppColors.lushPrimaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'IELTS NOTEBOOK',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lushPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kosakata Saya',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
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

                    const SizedBox(height: 24),

                    // Action Button: "+ Tambah Kosakata"
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lushPrimary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _openAddVocabulary,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'Tambah Kosakata',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Navigation Section Label
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        'NAVIGASI',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Menu: Beranda
                    _buildSidebarNavItem(
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                      badgeCount: null,
                      isSelected: _currentIndex == 0,
                      isDark: isDark,
                      onTap: () => _onTabSelected(0),
                    ),

                    const SizedBox(height: 4),

                    // Menu: Daftar Kosakata
                    _buildSidebarNavItem(
                      icon: Icons.menu_book_rounded,
                      label: 'Daftar Kosakata',
                      badgeCount: stats.total > 0 ? stats.total : null,
                      isSelected: _currentIndex == 1,
                      isDark: isDark,
                      onTap: () => _onTabSelected(1),
                    ),

                    const SizedBox(height: 4),

                    // Menu Shortcut: Kosakata Favorit
                    _buildSidebarNavItem(
                      icon: Icons.bookmark_rounded,
                      label: 'Kosakata Favorit',
                      badgeCount:
                          stats.favorites > 0 ? stats.favorites : null,
                      isSelected: false,
                      isDark: isDark,
                      onTap: _selectFavoritesTab,
                    ),

                    const SizedBox(height: 18),

                    // Navigation Section Label: Cadangan Data
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        'CADANGAN & DOKUMEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Menu: Sinkronisasi Cloud
                    _buildSidebarNavItem(
                      icon: Icons.cloud_sync_rounded,
                      label: ref.watch(isCloudConnectedProvider)
                          ? 'Cloud Tersambung'
                          : 'Sinkronisasi Cloud',
                      badgeCount: null,
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        CloudSyncModal.show(context);
                      },
                    ),

                    const SizedBox(height: 4),

                    // Menu: Ekspor ke PDF
                    _buildSidebarNavItem(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Ekspor ke PDF',
                      badgeCount: null,
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        final vocabs =
                            ref.read(vocabularyNotifierProvider).value ?? [];
                        ExportService.exportPdfStudySheet(
                          context: context,
                          vocabularies: vocabs,
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    // Menu: Backup JSON
                    _buildSidebarNavItem(
                      icon: Icons.download_rounded,
                      label: 'Backup Data (JSON)',
                      badgeCount: null,
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        final vocabs =
                            ref.read(vocabularyNotifierProvider).value ?? [];
                        final topics =
                            ref.read(customTopicsProvider).value ?? [];
                        ExportService.exportJsonBackup(
                          context: context,
                          vocabularies: vocabs,
                          customTopics: topics,
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    // Menu: Pulihkan Backup
                    _buildSidebarNavItem(
                      icon: Icons.upload_file_rounded,
                      label: 'Pulihkan Data',
                      badgeCount: null,
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        ExportService.importJsonBackup(
                          context: context,
                          ref: ref,
                        );
                      },
                    ),

                    if (kIsWeb) ...[
                      const SizedBox(height: 4),
                      // Menu: Segarkan Web
                      _buildSidebarNavItem(
                        icon: Icons.refresh_rounded,
                        label: 'Segarkan Web',
                        badgeCount: null,
                        isSelected: false,
                        isDark: isDark,
                        onTap: () {
                          ExportService.forceWebReload();
                        },
                      ),
                    ],

                    const Spacer(),
                    const SizedBox(height: 16),

                    // Bottom Quick Stats Banner in Sidebar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lushPrimaryLight
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lushBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Koleksi',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lushTextSecondary,
                                  ),
                                ),
                                Text(
                                  '${stats.total} Kata Tersimpan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
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

                    const SizedBox(height: 12),

                    // Theme Mode Switcher in Sidebar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lushBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lushPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isDark ? 'Mode Gelap' : 'Mode Terang',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lushTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: themeMode == ThemeMode.dark,
                            activeThumbColor: AppColors.darkPrimary,
                            onChanged: (val) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // App Version footer
                    Center(
                      child: Text(
                        '${AppConstants.appName} • Web & Responsive',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lushTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required int? badgeCount,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark
        ? AppColors.darkPrimary.withValues(alpha: 0.16)
        : AppColors.lushPrimaryLight;
    final activeColor =
        isDark ? AppColors.darkPrimary : AppColors.lushPrimary;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lushTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lushTextPrimary)
                        : inactiveColor,
                  ),
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.2)
                        : (isDark
                            ? AppColors.darkCard
                            : AppColors.lushBorder),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
