import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/cobrowse_service.dart';
import '../../yasli/screens/yasli_ana_sayfa.dart';

class AkrabaAnaSayfa extends ConsumerWidget {
  const AkrabaAnaSayfa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cagriDurumu = ref.watch(cagriDurumuProvider);

    return cagriDurumu.when(
      data: (tehlikeVarMi) => _AkrabaEkrani(tehlikeVarMi: tehlikeVarMi),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const Scaffold(body: Center(child: Text('Bağlantı hatası'))),
    );
  }
}

class _AkrabaEkrani extends StatefulWidget {
  final bool tehlikeVarMi;
  const _AkrabaEkrani({required this.tehlikeVarMi});

  @override
  State<_AkrabaEkrani> createState() => _AkrabaEkraniState();
}

class _AkrabaEkraniState extends State<_AkrabaEkrani> {
  bool baglaniyorMu = false;
  String? oturumKodu;

  Future<void> _baglan() async {
    setState(() => baglaniyorMu = true);
    try {
      final kod = await CobrowseService.oturumKoduAl();
      setState(() {
        oturumKodu = kod;
        baglaniyorMu = false;
      });
    } catch (e) {
      setState(() => baglaniyorMu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.tehlikeVarMi ? Colors.redAccent : Colors.green,
      appBar: AppBar(
        title: const Text('Akraba Takip Paneli'),
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
                widget.tehlikeVarMi
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              Text(
                widget.tehlikeVarMi
                    ? 'ACİL DURUM!\nYAKININIZ YARDIM BEKLİYOR!'
                    : 'HER ŞEY YOLUNDA\nYakınınız Güvende.',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Bağlan butonu
              if (oturumKodu == null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: baglaniyorMu ? null : _baglan,
                  icon: baglaniyorMu
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.screen_share),
                  label: Text(
                    baglaniyorMu ? 'Bağlanıyor...' : 'Ekranı Gör',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              // Oturum kodu göster
              if (oturumKodu != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Oturum Kodu',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        oturumKodu!,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cobrowse dashboard\'ından bu kodu girin',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => oturumKodu = null),
                  child: const Text('İptal',
                      style: TextStyle(color: Colors.white)),
                ),
              ],

              const SizedBox(height: 20),

              // Sıfırla butonu
              if (widget.tehlikeVarMi)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    await FirebaseService.sorunCozuldu();
                  },
                  child: const Text('SORUN ÇÖZÜLDÜ, SIFIRLA',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
