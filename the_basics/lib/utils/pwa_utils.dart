import 'dart:js_interop';

@JS('getDisplayMode')
external String _getDisplayMode();

bool isRunningAsPWA() {
  return _getDisplayMode() == 'standalone';
}
