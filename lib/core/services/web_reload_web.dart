import 'dart:js_interop';

@JS('forceAppUpdate')
external JSFunction? get _forceAppUpdateFunc;

@JS('location.reload')
external void _locationReload();

void triggerWebReload() {
  try {
    final func = _forceAppUpdateFunc;
    if (func != null) {
      func.callAsFunction();
      return;
    }
  } catch (_) {}
  try {
    _locationReload();
  } catch (_) {}
}
