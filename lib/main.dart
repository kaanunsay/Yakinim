import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAHdmt0aOrCRIlU0rPsRl1JasY9DauJJ8M",
      authDomain: "yakinim-2d372.firebaseapp.com",
      databaseURL: "https://yakinim-2d372-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "yakinim-2d372",
      storageBucket: "yakinim-2d372.firebasestorage.app",
      messagingSenderId: "775940299164",
      appId: "1:775940299164:web:037cddf355f07dbd189059",
    ),
  );

  runApp(const YakinimApp());
}

class YakinimApp extends StatelessWidget {
  const YakinimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YasliAnaSayfa(),
    );
  }
}

// ==========================================
// 1. EKRAN: YAŞLI EKRANI (DİNLEME ÖZELLİKLİ)
// ==========================================
class YasliAnaSayfa extends StatefulWidget {
  const YasliAnaSayfa({super.key});

  @override
  State<YasliAnaSayfa> createState() => _YasliAnaSayfaState();
}

class _YasliAnaSayfaState extends State<YasliAnaSayfa> {
  bool cagriYapildiMi = false;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    
    // Yaşlı ekranı da artık interneti dinliyor!
    // Yardımcı ekranı durumu sıfırlarsa, buradaki buton da anında kırmızıya geri dönecek.
    _databaseRef.child("cagri_sistemi").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          cagriYapildiMi = data["cagri_durumu"] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.supervisor_account, color: Colors.blue, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AkrabaAnaSayfa()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Teknik Destek Sistemi",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 50),
              
              GestureDetector(
                onTap: () async {
                  try {
                    await _databaseRef.child("cagri_sistemi").set({
                      "cagri_durumu": true,
                      "mesaj": "Kaan amca/teyze yardim bekliyor!"
                    });
                  } catch (e) {
                    print("Hata: $e");
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: cagriYapildiMi ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cagriYapildiMi ? "YARDIM İSTENDİ..." : "YARDIM ÇAĞIR",
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (cagriYapildiMi)
                const Text(
                  "Yakınınız aranıyor, lütfen bekleyin.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. EKRAN: YARDIMCI / AKRABA EKRANI
// ==========================================
class AkrabaAnaSayfa extends StatefulWidget {
  const AkrabaAnaSayfa({super.key});

  @override
  State<AkrabaAnaSayfa> createState() => _AkrabaAnaSayfaState();
}

class _AkrabaAnaSayfaState extends State<AkrabaAnaSayfa> {
  bool tehlikeVarMi = false;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _databaseRef.child("cagri_sistemi").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          tehlikeVarMi = data["cagri_durumu"] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tehlikeVarMi ? Colors.redAccent : Colors.green,
      appBar: AppBar(
        title: const Text("Akraba Takip Paneli"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tehlikeVarMi ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              Text(
                tehlikeVarMi ? "ACİL DURUM!\nYAKININIZ YARDIM BEKLİYOR!" : "HER ŞEY YOLUNDA\nYakınınız Güvende.",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              if (tehlikeVarMi)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    await _databaseRef.child("cagri_sistemi").set({
                      "cagri_durumu": false,
                      "mesaj": "Durum normal"
                    });
                  },
                  child: const Text("SORUN ÇÖZÜLDÜ, SIFIRLA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}