import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KronoPunchApp());
}

class KronoPunchApp extends StatelessWidget {
  const KronoPunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KronoPunch',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.light,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}