import 'package:flutter/material.dart';

void ignoreOverflowErrors(FlutterErrorDetails details, {bool forceReport = false}) {
  bool isOverflowError = false;
  bool isUnableToLoadAsset = false;

  var exception = details.exception;
  if (exception is FlutterError) {
    isOverflowError = exception.diagnostics.any(
          (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
    );
    isUnableToLoadAsset = exception.diagnostics.any(
          (e) => e.value.toString().startsWith("Unable to load asset"),
    );
  }

  if (isOverflowError || isUnableToLoadAsset) {
    debugPrint('Ignored Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}