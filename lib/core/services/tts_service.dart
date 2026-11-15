import 'package:flutter/material.dart';
import 'package:my_vocabulary/core/constants/app_colors.dart';
import 'tts_service_stub.dart'
    if (dart.library.js_interop) 'tts_service_web.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  factory TtsService() => instance;
  TtsService._internal();

  /// Speaks an English word or sentence with native pronunciation.
  /// [rate]: 0.82 for individual vocabulary (clear syllabic learning pace),
  ///         0.90 for full sentences.
  Future<void> speak(
    String text, {
    BuildContext? context,
    double rate = 0.82,
    String lang = 'en-US',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      await PlatformTts.speak(cleanText, rate: rate, lang: lang);

      if (context != null && context.mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? const Color(0xFF1B2C23) : const Color(0xFF0F382A),
            elevation: 4,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.3) : AppColors.lushPrimary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 1600),
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pelafalan Bahasa Inggris (TTS)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        cleanText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
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
    } catch (e) {
      debugPrint('TtsService.speak error: $e');
    }
  }

  /// Stops current speech audio.
  Future<void> stop() async {
    try {
      await PlatformTts.stop();
    } catch (e) {
      debugPrint('TtsService.stop error: $e');
    }
  }
}
