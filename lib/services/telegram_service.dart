// lib/services/telegram_service.dart
// Bridges Flutter (Dart) with the Telegram WebApp JavaScript SDK.
// Uses dart:js to call methods on window.Telegram.WebApp.
//
// The Telegram SDK is loaded in web/index.html via:
//   <script src="https://telegram.org/js/telegram-web-app.js"></script>

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  // Access the Telegram WebApp JS object safely
  js.JsObject? get _webApp {
    try {
      final tg = js.context['Telegram'];
      if (tg == null) return null;
      return tg['WebApp'] as js.JsObject?;
    } catch (_) {
      return null; // Running outside Telegram (e.g. browser dev mode)
    }
  }

  bool get isAvailable => _webApp != null;

  /// Tell Telegram the Mini App is ready to be shown (removes loading spinner)
  void ready() {
    _webApp?.callMethod('ready');
  }

  /// Expand the Mini App to full screen height
  void expand() {
    _webApp?.callMethod('expand');
  }

  /// Close the Mini App
  void close() {
    _webApp?.callMethod('close');
  }

  // --- Haptic Feedback ---
  // Useful for quiz correct/wrong answers and card flips

  void hapticImpact([String style = 'light']) {
    // style: 'light' | 'medium' | 'heavy' | 'rigid' | 'soft'
    _webApp?['HapticFeedback']?.callMethod('impactOccurred', [style]);
  }

  void hapticNotification(String type) {
    // type: 'error' | 'success' | 'warning'
    _webApp?['HapticFeedback']?.callMethod('notificationOccurred', [type]);
  }

  void hapticSelection() {
    _webApp?['HapticFeedback']?.callMethod('selectionChanged');
  }

  // --- Theme ---

  /// 'light' or 'dark' — follows user's Telegram theme
  String get colorScheme {
    return _webApp?['colorScheme']?.toString() ?? 'dark';
  }
}
