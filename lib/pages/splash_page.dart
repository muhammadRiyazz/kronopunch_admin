import 'package:flutter/material.dart';
import 'package:kronopunch/pages/auth/auth_home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(Duration(seconds: 2));
    // final exists = await FirebaseService.checkAnyCompanyExists();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AuthHomePage()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.access_time, color: Colors.white, size: 100),
          SizedBox(height: 20),
          Text('KronoPunch', style: TextStyle(fontSize: 32, color: Colors.white)),
        ]),
      ),
    );
  }
}
