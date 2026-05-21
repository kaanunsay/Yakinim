import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/cobrowse_service.dart';
import '../../yasli/screens/yasli_ana_sayfa.dart';

final kullaniciIsmiProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('kullanici_isim') ?? 'Akraba';
});

class AkrabaAnaSayfa extends ConsumerWidget {
  const AkrabaAnaSayfa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cagriDurumu = ref.watch(cagriDurumuProvider);
    final kullaniciIsmi = ref.watch(kullaniciIsmiProvider);

    return cagriDurumu.when(
      data: (tehlikeVarMi) => _AkrabaEkrani(
        tehlikeVarMi: tehlikeVarMi,
        isim: kullaniciIsmi.value ?? 'Akraba',
      ),
      loading: () => const Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF4A90D9)))),
      error: (e, _) => const Scaffold(
          backgroundColor: Color(0xFF1A1A2E),
          body: Center(child: Text('Bağlantı hatası', style: TextStyle(color: Colors.white)))),
    );
  }
}

class _AkrabaEkrani extends StatefulWidget {
  final bool tehlikeVarMi;
  final String isim;
  const _AkrabaEkrani({required this.tehlikeVarMi, required this.isim});

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
    final tehlikeRenk = const Color(0xFFE53935);
    final guvenliRenk = const Color(0xFF4A90D9);
    final aktifRenk = widget.tehlikeVarMi ? tehlikeRenk : guvenliRenk;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst başlık
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        widget.isim,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Durum kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: aktifRenk.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: aktifRenk.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.tehlikeVarMi
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 100,
                      color: aktifRenk,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.tehlikeVarMi
                          ? 'ACİL DURUM!'
                          : 'Her Şey Yolunda',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: aktifRenk,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tehlikeVarMi
                          ? 'Yakınınız yardım bekliyor!'
                          : 'Yakınınız güvende.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ekranı Gör butonu
              if (oturumKodu == null)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: baglaniyorMu ? null : _baglan,
                    icon: baglaniyorMu
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.screen_share, color: Colors.white),
                    label: Text(
                      baglaniyorMu ? 'Bağlanıyor...' : 'Ekranı Gör',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

              // Oturum kodu
              if (oturumKodu != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF4A90D9).withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      const Text('Oturum Kodu',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF888899))),
                      const SizedBox(height: 12),
                      Text(
                        oturumKodu!,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90D9),
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cobrowse dashboard\'ından bu kodu girin',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF888899)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => setState(() => oturumKodu = null),
                    child: const Text('İptal',
                        style: TextStyle(color: Color(0xFF888899))),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Sıfırla butonu
              if (widget.tehlikeVarMi)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tehlikeRenk,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () async {
                      await FirebaseService.sorunCozuldu();
                    },
                    child: const Text(
                      'SORUN ÇÖZÜLDÜ, SIFIRLA',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}