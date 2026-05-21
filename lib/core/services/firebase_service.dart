import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  // Eşleşme kodunu al
  static Future<String?> _eslesmeKoduAl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('eslesme_kodu');
  }

  // Akraba ismini Firebase'den çek
  static Future<String> akrabaIsmiAl() async {
    final kod = await _eslesmeKoduAl();
    if (kod == null) return 'Yakınınız';

    final snapshot = await _ref.child('kullanicilar/$kod/akraba/isim').get();
    return snapshot.value?.toString() ?? 'Yakınınız';
  }

  // Çağrı durumunu dinle
  static Stream<bool> cagriDurumuDinle() {
    return _ref.child('cagri_sistemi').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return data?['cagri_durumu'] ?? false;
    });
  }

  // Yardım çağrısı gönder
  static Future<void> yardimCagir() async {
    await _ref.child('cagri_sistemi').set({
      'cagri_durumu': true,
      'mesaj': 'Yakınınız yardım bekliyor!',
      'zaman': ServerValue.timestamp,
    });
  }

  // Durumu sıfırla
  static Future<void> sorunCozuldu() async {
    await _ref.child('cagri_sistemi').set({
      'cagri_durumu': false,
      'mesaj': 'Durum normal',
      'zaman': ServerValue.timestamp,
    });
  }
  static Future<bool> yasliVarMiKontrol() async {
  final prefs = await SharedPreferences.getInstance();
  final kod = prefs.getString('eslesme_kodu');
  if (kod == null) return false;

  final snapshot = await _ref.child('kullanicilar/$kod/yasli').get();
  return snapshot.exists;
}
}