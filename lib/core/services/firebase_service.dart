import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  static Stream<bool> cagriDurumuDinle() {
    return _ref.child('cagri_sistemi').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return data?['cagri_durumu'] ?? false;
    });
  }

  static Future<void> yardimCagir() async {
    await _ref.child('cagri_sistemi').set({
      'cagri_durumu': true,
      'mesaj': 'Yakınınız yardım bekliyor!',
      'zaman': ServerValue.timestamp,
    });
  }

  static Future<void> sorunCozuldu() async {
    await _ref.child('cagri_sistemi').set({
      'cagri_durumu': false,
      'mesaj': 'Durum normal',
      'zaman': ServerValue.timestamp,
    });
  }
}
