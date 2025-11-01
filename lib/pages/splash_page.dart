// lib/pages/splash_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kronopunch/models/company_model.dart';
import 'package:kronopunch/pages/auth/auth_home.dart';
import 'package:kronopunch/pages/dashboard/layout/main_layout.dart';
import 'package:kronopunch/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeApp();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  Future<Company?> _getCompanyData(String uid) async {
    try {
      debugPrint('🔄 Splash: Fetching company data for user: $uid');
      
      // Fetch company where uid matches the current user
      final snapshot = await FirebaseFirestore.instance
          .collection('companies')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final companyDoc = snapshot.docs.first;
        final company = Company.fromMap(companyDoc.data(), companyDoc.id);
        debugPrint('✅ Splash: Company data found: ${company.companyName}');
        return company;
      } else {
        debugPrint('❌ Splash: No company found for user: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Splash: Error fetching company data: $e');
      return null;
    }
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _status = 'Checking authentication...');
      debugPrint('🔄 Splash: Checking authentication status');
      
      // Check if user is logged in with Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      if (user != null) {
        debugPrint('✅ Splash: User is logged in, fetching company data...');
        setState(() => _status = 'Loading company data...');
        
        // Fetch company data for the logged-in user
        final company = await _getCompanyData(user.uid);
        
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        if (company != null) {
          debugPrint('✅ Splash: Company data loaded, redirecting to dashboard');
          setState(() => _status = 'Welcome back!');
          await Future.delayed(const Duration(milliseconds: 500));
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainLayout(company: company)),
          );
        } else {
          debugPrint('⚠️ Splash: User logged in but no company data found, redirecting to auth');
          setState(() => _status = 'Session expired...');
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Sign out and redirect to auth if company data is missing
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthHomePage()),
          );
        }
      } else {
        debugPrint('🔐 Splash: No user logged in, redirecting to auth');
        setState(() => _status = 'Redirecting to login...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthHomePage()),
        );
      }
    } catch (e) {
      debugPrint('❌ Splash: Error during initialization: $e');
      // If anything fails, go to auth page
      if (mounted) {
        setState(() => _status = 'Starting fresh...');
        await Future.delayed(const Duration(milliseconds: 1000));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthHomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFF303F9F),
              Color(0xFF5C6BC0),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: -50,
              right: -50,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Logo with Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF1A237E),
                        size: 60,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App Name with Slide Animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'KronoPunch',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tagline with Fade Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Smart Workforce Management',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 80,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [Colors.white, Colors.white70],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Loading Text with current status
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          _status,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Version/Bottom Text
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '© 2024 KronoPunch. All rights reserved',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}