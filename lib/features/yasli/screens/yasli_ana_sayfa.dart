import 'package:flutter/material.dart';
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                'Yakınım',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 50),
              cagriDurumu.when(
                data: (cagriYapildiMi) => _YardimButonu(cagriYapildiMi: cagriYapildiMi),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text('Bağlantı hatası'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YardimButonu extends StatelessWidget {
  final bool cagriYapildiMi;
  const _YardimButonu({required this.cagriYapildiMi});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: cagriYapildiMi ? null : () async {
            await FirebaseService.yardimCagir();
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
                cagriYapildiMi ? 'YARDIM İSTENDİ...' : 'YARDIM ÇAĞIR',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (cagriYapildiMi)
          const Text(
            'Yakınınız aranıyor, lütfen bekleyin.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}