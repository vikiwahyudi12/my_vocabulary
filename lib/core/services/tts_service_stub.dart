import 'package:flutter_tts/flutter_tts.dart';

class PlatformTts {
  static FlutterTts? _flutterTts;
  static bool _initialized = false;

  static Future<void> _ensureInit(double rate, String lang) async {
    if (_initialized && _flutterTts != null) return;
    try {
      _flutterTts ??= FlutterTts();
      await _flutterTts!.setLanguage(lang);
      // flutter_tts speech rate is usually between 0.0 and 1.0 (0.5 is default normal)
      await _flutterTts!.setSpeechRate(rate * 0.55);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _initialized = true;
    } catch (_) {}
  }

  static Future<void> speak(
    String text, {
    double rate = 0.85,
    String lang = 'en-US',
  }) async {
    try {
      await _ensureInit(rate, lang);
      await _flutterTts?.stop();
      await _flutterTts?.speak(text);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _flutterTts?.stop();
    } catch (_) {}
  }
}
