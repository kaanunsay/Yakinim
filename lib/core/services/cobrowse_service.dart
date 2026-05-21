import 'package:flutter/services.dart';

class CobrowseService {
  static const _channel = MethodChannel('com.yakinim/cobrowse');

  static Function()? onOturumBasladi;
  static Function()? onOturumBitti;

  static void dinlemeBaslat() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'oturumBasladi':
          onOturumBasladi?.call();
          break;
        case 'oturumBitti':
          onOturumBitti?.call();
          break;
      }
    });
  }

  static Future<void> initialize() async {
    dinlemeBaslat();
  }

  static Future<String?> oturumKoduAl() async {
    try {
      final String? kod = await _channel.invokeMethod('oturumKoduAl');
      return kod;
    } catch (e) {
      return null;
    }
  }

  static Future<void> oturumaBaglan(String kod) async {
    try {
      await _channel.invokeMethod('oturumaBaglan', {'kod': kod});
    } catch (e) {
      // sessizce geç
    }
  }

  static Future<void> cobrowseBaslat() async {
    try {
      await _channel.invokeMethod('cobrowseBaslat');
    } catch (e) {
      // sessizce geç
    }
  }
}
