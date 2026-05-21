import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kullanici_model.dart';

class AuthService {
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  //6 haneli rastgele kod üret
  //Uygulamayı piyasaya sürersem bunu harflerle değiştir
  static String kodUret() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }


  // Akraba kaydı oluşturup Firebase'e yazma
  static Future<String> akrabaKayit(String isim) async {
    final kod=kodUret();
    final id = 'akraba_${DateTime.now().millisecondsSinceEpoch}';

    final kullanici=KullaniciModel(
      id: id, 
      isim: isim, 
      rol: 'akraba', 
      eslesmeKodu: kod,
      );

      await _ref.child('kullanicilar/$kod/akraba').set(kullanici.toMap());

      //cihaza kaydetme(sharedPreferences)
      final prefs=await SharedPreferences.getInstance();
      await prefs.setString('kullanici_id', id);
      await prefs.setString('kullanici_rol', 'akraba');
      await prefs.setString('kullanici_isim', isim);
      await prefs.setString('eslesme_kodu', kod);

      return kod;
  }

  static Future<bool>yasliKayit(String isim, String kod) async{
    final kontrol=await _ref.child('kullanicilar/$kod/akraba').get();

    if(!kontrol.exists)
      return false;

    final id = 'yasli_${DateTime.now().millisecondsSinceEpoch}';

    final kullanici=KullaniciModel(
      id: id,
      isim: isim,
      rol: 'yasli',
      eslesmeKodu: kod,
    );

    await _ref.child('kullanicilar/$kod/yasli').set(kullanici.toMap());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullanici_id', id);
    await prefs.setString('kullanici_rol', 'yasli');
    await prefs.setString('kullanici_isim', isim);
    await prefs.setString('eslesme_kodu', kod);

    return true;
  }

  //girmiş mi kontrol
  static Future<Map<String,String>?> girisKontrol() async {
    final prefs=await SharedPreferences.getInstance();
    final rol=prefs.getString('kullanici_rol');
    if(rol==null) 
      return null;
    
    return {
      'rol': rol,
      'isim':prefs.getString('kullanici_isim') ?? '',
      'eslesmeKodu': prefs.getString('eslesme_kodu') ?? '',  
    };

  }
  
  static Future<void> cikis() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}