import 'dart:js_interop';

@JS('canInstallPWA')
external bool get _canInstallPWA;

@JS('triggerPWAInstall')
external JSPromise<JSBoolean> _triggerPWAInstall();

bool canInstallPWA() {
  return _canInstallPWA;
}

Future<bool> triggerInstallPWA() async {
  final jsResult = await _triggerPWAInstall().toDart;
  return jsResult.toDart;
}
