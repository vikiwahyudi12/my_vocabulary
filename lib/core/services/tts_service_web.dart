import 'dart:js_interop';

@JS('appSpeakText')
external JSBoolean _jsAppSpeakText(JSString text, [JSNumber? rate, JSString? lang]);

@JS('appStopSpeech')
external void _jsAppStopSpeech();

class PlatformTts {
  static Future<void> speak(
    String text, {
    double rate = 0.85,
    String lang = 'en-US',
  }) async {
    try {
      _jsAppSpeakText(text.toJS, rate.toJS, lang.toJS);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      _jsAppStopSpeech();
    } catch (_) {}
  }
}
