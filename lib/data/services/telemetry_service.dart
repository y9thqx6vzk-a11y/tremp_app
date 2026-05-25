import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  /// מאתחל את שירות ה-Sentry לניטור קריסות ושגיאות ב-Production
  static Future<void> init(Future<void> Function() appRunner, String dsn) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 1.0; // תיעוד מלא לבדיקת ביצועים
      },
      appRunner: appRunner,
    );
  }

  /// תיעוד לוגים בסיסיים
  static void logInfo(String message, {Map<String, dynamic>? data}) {
    debugPrint('ℹ️ [INFO] $message | Data: $data');
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      data: data,
      level: SentryLevel.info,
    ));
  }

  /// תיעוד אירועים משמעותיים באפליקציה (כמו "חישוב מסלול הצליח")
  static void logEvent(String eventName, {Map<String, dynamic>? properties}) {
    debugPrint('📊 [EVENT] $eventName | Props: $properties');
    Sentry.captureMessage(
      'Event: $eventName',
      level: SentryLevel.info,
      withScope: (scope) {
        if (properties != null) {
          scope.setContexts('event_properties', properties);
        }
      },
    );
  }

  /// תיעוד שגיאות וקריסות
  static void logError(dynamic exception, dynamic stackTrace, {String? hint}) {
    debugPrint('❌ [ERROR] $hint | Exception: $exception');
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (hint != null) scope.setExtra('hint', hint);
      },
    );
  }
}
