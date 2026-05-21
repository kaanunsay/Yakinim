import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/cobrowse_service.dart';
import 'features/yasli/screens/yasli_ana_sayfa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
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
    } else {
      await Firebase.initializeApp();
    }
  }

  await CobrowseService.initialize();

  runApp(
    const ProviderScope(
      child: YakinimApp(),
    ),
  );
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
