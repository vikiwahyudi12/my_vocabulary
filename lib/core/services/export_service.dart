import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/vocabulary_model.dart';
import '../../providers/vocabulary_provider.dart';
import '../constants/app_colors.dart';

class ExportService {
  /// Export all vocabularies to a formatted JSON backup file
  static Future<void> exportJsonBackup({
    required BuildContext context,
    required List<Vocabulary> vocabularies,
    required List<String> customTopics,
  }) async {
    try {
      final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final backupData = {
        'app': 'IELTS Vocabulary Notebook',
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'total_words': vocabularies.length,
        'custom_topics': customTopics,
        'vocabularies': vocabularies.map((v) => v.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final fileName = 'ielts_vocabulary_backup_$nowStr.json';

      // Using Printing.sharePdf which downloads the file in browser on web
      // and opens share/save dialog on mobile/desktop
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.lushPrimary,
            content: Text('Berhasil mengekspor backup ($fileName)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal mengekspor data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Import vocabularies from a previously saved JSON backup file
  static Future<void> importJsonBackup({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return; // User canceled
      }

      final jsonContent = await files.first.xFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonContent);

      final vocabListRaw = data['vocabularies'] as List<dynamic>?;
      if (vocabListRaw == null) {
        throw Exception('Format backup tidak valid (data kosakata tidak ditemukan).');
      }

      final importedVocabs = vocabListRaw
          .map((item) => Vocabulary.fromMap(item as Map<String, dynamic>))
          .toList();

      final customTopics = (data['custom_topics'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [];

      if (!context.mounted) return;

      // Ask user whether to Merge or Replace
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Pulihkan Data Kosakata',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ditemukan ${importedVocabs.length} kata dari file backup.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pilih metode pemulihan yang diinginkan:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lushTextSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lushTextPrimary,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, 'merge'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Gabungkan'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'replace'),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lushPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ganti Semua'),
              ),
            ],
          );
        },
      );

      if (action == null || !context.mounted) return;

      final db = ref.read(databaseProvider);

      if (action == 'replace') {
        final existing = await db.getAllVocabularies();
        for (final v in existing) {
          if (v.id != null) {
            await db.deleteVocabulary(v.id!);
          }
        }
      }

      // Insert imported vocabularies
      for (final vocab in importedVocabs) {
        // Create clean entry without existing ID to avoid conflicts
        final toInsert = Vocabulary(
          word: vocab.word,
          meaning: vocab.meaning,
          level: vocab.level,
          phonetic: vocab.phonetic,
          definition: vocab.definition,
          example: vocab.example,
          exampleTranslation: vocab.exampleTranslation,
          partOfSpeech: vocab.partOfSpeech,
          usageCategories: vocab.usageCategories,
          topics: vocab.topics,
          notes: vocab.notes,
          isFavorite: vocab.isFavorite,
          createdAt: vocab.createdAt,
          updatedAt: vocab.updatedAt,
        );
        await db.insertVocabulary(toInsert);
      }

      // Insert custom topics
      for (final topic in customTopics) {
        await db.addCustomTopic(topic);
      }

      // Reload state
      await ref.read(vocabularyNotifierProvider.notifier).loadVocabularies();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.lushPrimary,
            content: Text(
              'Berhasil memulihkan ${importedVocabs.length} kosakata!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal memulihkan backup: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Export vocabularies to a clean, printable PDF study document
  static Future<void> exportPdfStudySheet({
    required BuildContext context,
    required List<Vocabulary> vocabularies,
  }) async {
    try {
      final doc = pw.Document();
      final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

      // Emerald Theme Colors for PDF
      final primaryColor = PdfColor.fromHex('#0E7A53');
      final secondaryBg = PdfColor.fromHex('#F4FBF7');
      final textColor = PdfColor.fromHex('#17241E');
      final mutedColor = PdfColor.fromHex('#53665C');
      final borderColor = PdfColor.fromHex('#D2E9DC');

      // Chunk vocabularies across pages (8 words per page)
      const wordsPerPage = 6;
      final totalPages = (vocabularies.length / wordsPerPage).ceil();

      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final start = pageIndex * wordsPerPage;
        final end = (start + wordsPerPage < vocabularies.length)
            ? start + wordsPerPage
            : vocabularies.length;
        final pageVocabs = vocabularies.sublist(start, end);

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Page Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'IELTS VOCABULARY NOTEBOOK',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Lembar Belajar Kosakata',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        '$dateStr • Hal ${pageIndex + 1}/$totalPages',
                        style: pw.TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: borderColor, thickness: 1),
                  pw.SizedBox(height: 14),

                  // Vocab Cards List
                  ...pageVocabs.map((v) {
                    final isAdvance = v.isAdvance;
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: secondaryBg,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                        border: pw.Border.all(color: borderColor, width: 0.8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Top row: Word, Phonetic, Level badge
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Text(
                                    v.word,
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  if (v.phonetic != null &&
                                      v.phonetic!.isNotEmpty) ...[
                                    pw.SizedBox(width: 6),
                                    pw.Text(
                                      v.phonetic!,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        color: mutedColor,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: isAdvance ? primaryColor : borderColor,
                                  borderRadius: const pw.BorderRadius.all(
                                    pw.Radius.circular(4),
                                  ),
                                ),
                                child: pw.Text(
                                  isAdvance ? 'Band 7.0+' : 'Band 5.5+',
                                  style: pw.TextStyle(
                                    color: isAdvance
                                        ? PdfColors.white
                                        : textColor,
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),

                          // Meaning
                          pw.Text(
                            'Arti: ${v.meaning}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          // Categories / Topics
                          if (v.usageCategories.isNotEmpty ||
                              v.topics.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Penggunaan: ${v.usageCategories.join(", ")} • Topik: ${v.topics.join(", ")}',
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                color: mutedColor,
                              ),
                            ),
                          ],

                          // Example
                          if (v.example != null &&
                              v.example!.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'Contoh: "${v.example}"',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: textColor,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                            if (v.exampleTranslation != null &&
                                v.exampleTranslation!.trim().isNotEmpty) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Terjemahan: ${v.exampleTranslation}',
                                style: pw.TextStyle(
                                  fontSize: 9.5,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    );
                  }),

                  pw.Spacer(),
                  // Footer
                  pw.Divider(color: borderColor, thickness: 0.5),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'vocabulary.vikijournal.tech',
                        style: pw.TextStyle(fontSize: 8.5, color: primaryColor),
                      ),
                      pw.Text(
                        'Total: ${vocabularies.length} kosakata',
                        style: pw.TextStyle(fontSize: 8.5, color: mutedColor),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      final nowStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final pdfBytes = await doc.save();

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'ielts_vocabulary_$nowStr.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.lushPrimary,
            content: const Text('Berhasil membuka dokumen PDF!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal membuat PDF: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
