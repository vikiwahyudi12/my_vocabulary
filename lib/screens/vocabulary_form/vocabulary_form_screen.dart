import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/vocabulary_provider.dart';

class VocabularyFormScreen extends ConsumerStatefulWidget {
  final Vocabulary? vocabularyToEdit;

  const VocabularyFormScreen({
    super.key,
    this.vocabularyToEdit,
  });

  @override
  ConsumerState<VocabularyFormScreen> createState() => _VocabularyFormScreenState();
}

class _VocabularyFormScreenState extends ConsumerState<VocabularyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _wordController;
  late TextEditingController _meaningController;
  late TextEditingController _phoneticController;
  late TextEditingController _definitionController;
  late TextEditingController _exampleController;
  late TextEditingController _exampleTranslationController;
  late TextEditingController _notesController;

  late String _selectedLevel;
  String? _selectedPartOfSpeech;
  late Set<String> _selectedUsage;
  late Set<String> _selectedTopics;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.vocabularyToEdit;

    _wordController = TextEditingController(text: edit?.word ?? '');
    _meaningController = TextEditingController(text: edit?.meaning ?? '');
    _phoneticController = TextEditingController(text: edit?.phonetic ?? '');
    _definitionController = TextEditingController(text: edit?.definition ?? '');
    _exampleController = TextEditingController(text: edit?.example ?? '');
    _exampleTranslationController =
        TextEditingController(text: edit?.exampleTranslation ?? '');
    _notesController = TextEditingController(text: edit?.notes ?? '');

    _selectedLevel = edit?.level ?? 'Advance';
    _selectedPartOfSpeech = edit?.partOfSpeech;
    _selectedUsage = edit != null
        ? Set<String>.from(edit.usageCategories)
        : {'General'};
    _selectedTopics = edit != null ? Set<String>.from(edit.topics) : {'Other'};
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _phoneticController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showAddCustomTopicDialog() async {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newTopic = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Topik Baru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Media, Architecture, Sports',
              labelText: 'Nama Topik',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(ctx, text);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    if (newTopic != null && newTopic.isNotEmpty) {
      await ref.read(customTopicsProvider.notifier).addTopic(newTopic);
      setState(() {
        _selectedTopics.add(newTopic);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUsage.isEmpty) {
      _selectedUsage.add('General');
    }
    if (_selectedTopics.isEmpty) {
      _selectedTopics.add('Other');
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final edit = widget.vocabularyToEdit;

      final newOrUpdatedVocab = Vocabulary(
        id: edit?.id,
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        level: _selectedLevel,
        phonetic: _phoneticController.text.trim().isEmpty
            ? null
            : _phoneticController.text.trim(),
        definition: _definitionController.text.trim().isEmpty
            ? null
            : _definitionController.text.trim(),
        example: _exampleController.text.trim().isEmpty
            ? null
            : _exampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim().isEmpty
            ? null
            : _exampleTranslationController.text.trim(),
        partOfSpeech: _selectedPartOfSpeech,
        usageCategories: _selectedUsage.toList(),
        topics: _selectedTopics.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isFavorite: edit?.isFavorite ?? false,
        createdAt: edit?.createdAt ?? now,
        updatedAt: now,
      );

      final notifier = ref.read(vocabularyNotifierProvider.notifier);
      if (edit != null) {
        await notifier.updateVocabulary(newOrUpdatedVocab).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Waktu simpan habis (timeout). Silakan coba lagi.',
          ),
        );
      } else {
        await notifier.addVocabulary(newOrUpdatedVocab).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Waktu simpan habis (timeout). Silakan coba lagi.',
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.lushPrimary,
            content: Text(
              edit != null
                  ? 'Berhasil memperbarui "${newOrUpdatedVocab.word}"'
                  : 'Berhasil menyimpan "${newOrUpdatedVocab.word}"',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vocabularyToEdit != null;
    final allTopics = ref.watch(allTopicsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          isEdit ? 'Edit Kosakata' : 'Tambah Kosakata',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lushPrimary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
            _buildSectionHeader(
              title: 'DETAIL UTAMA',
              subtitle: 'Kata, arti Indonesia, dan level kosakata',
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // English Word / Phrase
            TextFormField(
              controller: _wordController,
              autofocus: !isEdit,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Kata atau Frasa Bahasa Inggris *',
                hintText: 'e.g. In a nutshell, Mitigate',
                prefixIcon: Icon(Icons.translate, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Silakan masukkan kata atau frasa';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Indonesian Meaning
            TextFormField(
              controller: _meaningController,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Arti Bahasa Indonesia *',
                hintText: 'e.g. Singkatnya / kesimpulannya',
                prefixIcon: Icon(Icons.menu_book, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Silakan masukkan arti dalam bahasa Indonesia';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Phonetics
            TextFormField(
              controller: _phoneticController,
              style: const TextStyle(fontSize: 14, fontFamily: 'Courier'),
              decoration: const InputDecoration(
                labelText: 'Pelafalan / Fonetik (Opsional)',
                hintText: "e.g. /ɪn ə 'nʌt.ʃɛl/",
                prefixIcon: Icon(Icons.record_voice_over_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Level Selector (Basic vs Advance)
            _buildSectionHeader(
              title: 'LEVEL KOSAKATA',
              subtitle: 'Pilih Basic (dasar) atau Advance (Band 7+)',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLevel = 'Basic';
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedLevel == 'Basic'
                            ? (isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9))
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedLevel == 'Basic'
                              ? const Color(0xFF4CAF50)
                              : (isDark ? AppColors.darkBorder : AppColors.lushBorder),
                          width: _selectedLevel == 'Basic' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: _selectedLevel == 'Basic'
                                ? const Color(0xFF2E7D32)
                                : (isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Basic',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedLevel == 'Basic' ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedLevel == 'Basic'
                                  ? const Color(0xFF2E7D32)
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLevel = 'Advance';
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedLevel == 'Advance'
                            ? (isDark ? const Color(0xFF2C1E38) : const Color(0xFFF3E8FA))
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedLevel == 'Advance'
                              ? const Color(0xFFAB47BC)
                              : (isDark ? AppColors.darkBorder : AppColors.lushBorder),
                          width: _selectedLevel == 'Advance' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: _selectedLevel == 'Advance'
                                ? const Color(0xFF7B1FA2)
                                : (isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Advance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedLevel == 'Advance' ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedLevel == 'Advance'
                                  ? const Color(0xFF7B1FA2)
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lushTextPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Usage Category Multi-Select
            _buildSectionHeader(
              title: 'KATEGORI PENGGUNAAN (MULTI-SELECT)',
              subtitle: 'Keahlian IELTS di mana kata ini cocok digunakan',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.usageCategories.map((usage) {
                final isSelected = _selectedUsage.contains(usage);
                return FilterChip(
                  label: Text(usage),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedUsage.add(usage);
                      } else {
                        if (_selectedUsage.length > 1) {
                          _selectedUsage.remove(usage);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Topic Category Multi-Select
            _buildSectionHeader(
              title: 'TOPIK KOSAKATA (MULTI-SELECT)',
              subtitle: 'Tema esai atau speaking terkait',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...allTopics.map((topic) {
                  final isSelected = _selectedTopics.contains(topic);
                  return FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTopics.add(topic);
                        } else {
                          if (_selectedTopics.length > 1) {
                            _selectedTopics.remove(topic);
                          }
                        }
                      });
                    },
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Topik'),
                  onPressed: _showAddCustomTopicDialog,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Part of Speech Selection (Optional)
            _buildSectionHeader(
              title: 'KELAS KATA (OPSIONAL)',
              subtitle: 'Pilih part of speech',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.partsOfSpeech.map((pos) {
                final isSelected = _selectedPartOfSpeech == pos;
                return ChoiceChip(
                  label: Text(pos),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPartOfSpeech = selected ? pos : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Additional Optional Details
            _buildSectionHeader(
              title: 'DETAIL TAMBAHAN (OPSIONAL)',
              subtitle: 'Definisi, contoh kalimat, dan tips IELTS',
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // English Definition
            TextFormField(
              controller: _definitionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Definisi Bahasa Inggris',
                hintText: 'Penjelasan singkat dalam bahasa Inggris',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            // Example Sentence
            TextFormField(
              controller: _exampleController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Contoh Kalimat',
                hintText: 'e.g. In a few words; summarized concisely into the main takeaway.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            // Indonesian Translation of Example
            TextFormField(
              controller: _exampleTranslationController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Terjemahan Contoh Kalimat',
                hintText: 'Arti kalimat contoh dalam bahasa Indonesia',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            // Notes / IELTS Tips
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan & Tips IELTS',
                hintText: 'e.g. Kolokasi, sinonim, atau perbandingan Basic ➔ Advance',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lushTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lushTextMuted,
          ),
        ),
      ],
    );
  }
}
