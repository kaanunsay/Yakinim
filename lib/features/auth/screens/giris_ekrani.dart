import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../yasli/screens/yasli_ana_sayfa.dart';
import '../../akraba/screens/akraba_ana_sayfa.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  String? seciliRol; // 'yasli' veya 'akraba'
  final isimController = TextEditingController();
  final kodController = TextEditingController();
  bool yukleniyor = false;
  String? hata;
  String? olusturulanKod; // Akraba için oluşturulan kod

  @override
  void dispose() {
    isimController.dispose();
    kodController.dispose();
    super.dispose();
  }

  Future<void> _devam() async {
    if (isimController.text.trim().isEmpty) {
      setState(() => hata = 'Lütfen isminizi girin.');
      return;
    }

    if (seciliRol == 'yasli' && kodController.text.trim().length != 6) {
      setState(() => hata = 'Lütfen 6 haneli kodu girin.');
      return;
    }

    setState(() {
      yukleniyor = true;
      hata = null;
    });

    try {
      if (seciliRol == 'akraba') {
        final kod = await AuthService.akrabaKayit(isimController.text.trim());
        setState(() {
          olusturulanKod = kod;
          yukleniyor = false;
        });
      } else {
        final basarili = await AuthService.yasliKayit(
          isimController.text.trim(),
          kodController.text.trim(),
        );

        if (!basarili) {
          setState(() {
            hata = 'Kod bulunamadı. Lütfen kontrol edin.';
            yukleniyor = false;
          });
          return;
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const YasliAnaSayfa()),
          );
        }
      }
    } catch (e) {
      setState(() {
        hata = 'Bir hata oluştu, tekrar deneyin.';
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: olusturulanKod != null
                ? _KodGosterEkrani(
                    kod: olusturulanKod!,
                    onward: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AkrabaAnaSayfa()),
                      );
                    },
                  )
                : seciliRol == null
                    ? _RolSecimi(onSecim: (rol) {
                        setState(() => seciliRol = rol);
                      })
                    : _KayitFormu(
                        rol: seciliRol!,
                        isimController: isimController,
                        kodController: kodController,
                        yukleniyor: yukleniyor,
                        hata: hata,
                        onDevam: _devam,
                        onGeri: () => setState(() {
                          seciliRol = null;
                          hata = null;
                        }),
                      ),
          ),
        ),
      ),
    );
  }
}

// Rol seçimi ekranı
class _RolSecimi extends StatelessWidget {
  final Function(String) onSecim;
  const _RolSecimi({required this.onSecim});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Yakınım',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Seni nasıl tanımlayalım?',
          style: TextStyle(fontSize: 18, color: Color(0xFF888899)),
        ),
        const SizedBox(height: 60),

        // Yaşlı butonu
        _RolKarti(
          ikon: Icons.elderly_rounded,
          baslik: 'Yardıma İhtiyacım Var',
          aciklama: 'Yakınımdan yardım isteyeceğim',
          renk: const Color(0xFFE53935),
          onTap: () => onSecim('yasli'),
        ),

        const SizedBox(height: 20),

        // Akraba butonu
        _RolKarti(
          ikon: Icons.favorite_rounded,
          baslik: 'Yardım Edeceğim',
          aciklama: 'Yakınımı takip edeceğim',
          renk: const Color(0xFF4A90D9),
          onTap: () => onSecim('akraba'),
        ),
      ],
    );
  }
}

class _RolKarti extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String aciklama;
  final Color renk;
  final VoidCallback onTap;

  const _RolKarti({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.renk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: renk.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: renk.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(ikon, color: renk, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(aciklama,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF888899))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: renk, size: 18),
          ],
        ),
      ),
    );
  }
}

// Kayıt formu
class _KayitFormu extends StatelessWidget {
  final String rol;
  final TextEditingController isimController;
  final TextEditingController kodController;
  final bool yukleniyor;
  final String? hata;
  final VoidCallback onDevam;
  final VoidCallback onGeri;

  const _KayitFormu({
    required this.rol,
    required this.isimController,
    required this.kodController,
    required this.yukleniyor,
    required this.hata,
    required this.onDevam,
    required this.onGeri,
  });

  @override
  Widget build(BuildContext context) {
    final renk =
        rol == 'akraba' ? const Color(0xFF4A90D9) : const Color(0xFFE53935);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onGeri,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          rol == 'akraba' ? 'Yardım Eden' : 'Yardıma İhtiyacım Var',
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          rol == 'akraba'
              ? 'Bilgilerini gir, eşleşme kodunu yakınınla paylaş.'
              : 'Bilgilerini gir, akrabanın verdiği kodu gir.',
          style:
              const TextStyle(fontSize: 15, color: Color(0xFF888899)),
        ),
        const SizedBox(height: 40),

        // İsim alanı
        _InputAlani(
          controller: isimController,
          label: 'İsmin',
          ikon: Icons.person_rounded,
          renk: renk,
        ),

        // Yaşlı için kod alanı
        if (rol == 'yasli') ...[
          const SizedBox(height: 16),
          _InputAlani(
            controller: kodController,
            label: 'Eşleşme Kodu (6 hane)',
            ikon: Icons.key_rounded,
            renk: renk,
            sayisal: true,
            maxLength: 6,
          ),
        ],

        if (hata != null) ...[
          const SizedBox(height: 16),
          Text(hata!,
              style: const TextStyle(color: Color(0xFFE53935), fontSize: 14)),
        ],

        const SizedBox(height: 32),

        // Devam butonu
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: renk,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: yukleniyor ? null : onDevam,
            child: yukleniyor
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Devam Et',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _InputAlani extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData ikon;
  final Color renk;
  final bool sayisal;
  final int? maxLength;

  const _InputAlani({
    required this.controller,
    required this.label,
    required this.ikon,
    required this.renk,
    this.sayisal = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: sayisal ? TextInputType.number : TextInputType.name,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF888899)),
        prefixIcon: Icon(ikon, color: renk),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: renk, width: 1.5),
        ),
        counterStyle: const TextStyle(color: Color(0xFF888899)),
      ),
    );
  }
}

// Akraba için oluşturulan kodu göster
class _KodGosterEkrani extends StatelessWidget {
  final String kod;
  final VoidCallback onward;

  const _KodGosterEkrani({required this.kod, required this.onward});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF4A90D9), size: 80),
        const SizedBox(height: 24),
        const Text(
          'Eşleşme Kodun',
          style: TextStyle(fontSize: 22, color: Color(0xFF888899)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF4A90D9).withOpacity(0.4), width: 1.5),
          ),
          child: Text(
            kod,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90D9),
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bu kodu yakınınıza verin.\nYakınınız uygulamayı kurduğunda bu kodu girecek.',
          style: TextStyle(fontSize: 16, color: Color(0xFF888899)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90D9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: onward,
            child: const Text(
              'Devam Et',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}