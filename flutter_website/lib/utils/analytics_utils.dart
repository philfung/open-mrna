import 'dart:js_interop';
import 'package:flutter/foundation.dart';

@JS('gtag')
external void _gtag(String type, String eventName, [JSAny? parameters]);

class AnalyticsUtils {
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    if (!kIsWeb) return;

    try {
      if (parameters != null) {
        _gtag('event', name, parameters.jsify());
      } else {
        _gtag('event', name);
      }
      debugPrint('GA4 Event logged: $name ${parameters ?? ""}');
    } catch (e) {
      debugPrint('Error logging GA4 event: $e');
    }
  }
}
