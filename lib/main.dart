import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? erroFirebase;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    erroFirebase =
        'Firebase indisponível. Confira a configuração e a conexão. '
        'Consulte as instruções no README.';
  }
  runApp(FitTrackApp(erroFirebase: erroFirebase));
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key, this.erroFirebase});
  final String? erroFirebase;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitTrack',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E676),
        surface: Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(20),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
    ),
    home: HomePage(erroFirebase: erroFirebase),
  );
}
