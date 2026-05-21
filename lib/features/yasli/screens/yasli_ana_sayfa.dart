import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../akraba/screens/akraba_ana_sayfa.dart';

final cagriDurumuProvider = StreamProvider<bool>((ref) {
  return FirebaseService.cagriDurumuDinle();
});

class YasliAnaSayfa extends ConsumerWidget {
  const YasliAnaSayfa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cagriDurumu = ref.watch(cagriDurumuProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.supervisor_account,
                    color: Color(0xFF444466), size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AkrabaAnaSayfa()),
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: cagriDurumu.when(
                  data: (cagriYapildiMi) =>
                      _YasliIcerik(cagriYapildiMi: cagriYapildiMi),
                  loading: () => const CircularProgressIndicator(
                      color: Color(0xFF4A90D9)),
                  error: (e, _) => const _HataMesaji(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YasliIcerik extends StatelessWidget {
  final bool cagriYapildiMi;
  const _YasliIcerik({required this.cagriYapildiMi});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Üst mesaj
        Text(
          cagriYapildiMi ? 'Nadir geliyor...' : 'Yardıma mı ihtiyacın var?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: cagriYapildiMi
                ? const Color(0xFF4A90D9)
                : const Color(0xFFCCCCDD),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // Ana buton
        GestureDetector(
          onTap: cagriYapildiMi
              ? null
              : () async {
                  HapticFeedback.heavyImpact();
                  await FirebaseService.yardimCagir();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: cagriYapildiMi
                  ? const Color(0xFF1A5276)
                  : const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (cagriYapildiMi
                          ? const Color(0xFF1A5276)
                          : const Color(0xFFE53935))
                      .withOpacity(0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cagriYapildiMi
                      ? Icons.phone_in_talk_rounded
                      : Icons.pan_tool_rounded,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  cagriYapildiMi ? 'BEKLİYORUM...' : 'NADİR\'İ ÇAĞIR',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),

        if (cagriYapildiMi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4A90D9).withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF4A90D9), size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Nadir\'e haber verildi, lütfen bekleyin.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4A90D9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'Butona bas, Nadir hemen yardıma gelsin.',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF666688),
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _HataMesaji extends StatelessWidget {
  const _HataMesaji();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off_rounded, size: 64, color: Color(0xFF444466)),
        SizedBox(height: 16),
        Text(
          'İnternet bağlantısı yok',
          style: TextStyle(fontSize: 22, color: Color(0xFF666688)),
        ),
      ],
    );
  }
}