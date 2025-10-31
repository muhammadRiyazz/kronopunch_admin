// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kronopunch/services/cache_service.dart';
import 'package:kronopunch/services/login_cache.dart';
import '../models/company_model.dart';
import 'dart:developer';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // 🔹 Register new company (Auth + Company Code)
  static Future<void> registerCompany({
    required String email,
    required Company company,
  }) async {
    // 🔹 1. Create Firebase Auth user (Admin)
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: company.password,
    );

    final uid = userCredential.user?.uid;

    // 🔹 2. Get the last company code
    final snapshot = await _firestore
        .collection('companies')
        .orderBy('companyCode', descending: true)
        .limit(1)
        .get();

    String nextCompanyCode = 'company_001';

    if (snapshot.docs.isNotEmpty) {
      final lastCode = snapshot.docs.first['companyCode'];
      final number = int.parse(lastCode.split('_').last);
      nextCompanyCode = 'company_${(number + 1).toString().padLeft(3, '0')}';
    }

    // 🔹 3. Create the company document
    final companyRef = _firestore.collection('companies').doc(nextCompanyCode);

    await companyRef.set({
      'companyName': company.companyName,
      'password': company.password,
      'email': company.email,
      'phone': company.phone,
      'altPhone': company.altPhone,
      'state': company.state,
      'district': company.district,
      'address': company.address,
      'description': company.description,
      'companyCode': nextCompanyCode,
      'createdAt': company.createdAt,
      'uid': uid,
    });

    // 🔹 4. Add admin user under this company's "users" subcollection
    final adminUser = {
      'uid': uid,
      'email': email,
      'name': '${company.companyName} Admin',
      'role': 'admin',
      'companyCode': nextCompanyCode,
      'createdAt': DateTime.now(),
      'status': 'active',
    };

    await companyRef.collection('users').doc(uid).set(adminUser);

    // 🔹 5. Save to cache
    await CacheService.saveLoginData(
      companyCode: nextCompanyCode,
      email: email,
      name: '${company.companyName} Admin',
      role: 'admin',
    );

    log("✅ Company Registered ($nextCompanyCode) with Admin User ($uid)");
  }

  // 🔹 Login existing company
  static Future<Company?> loginCompany({
    required String email,
    required String password,
  }) async {
    // 1️⃣ Firebase Auth sign in
    UserCredential userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCred.user!.uid;

    // 2️⃣ Fetch company where uid == this user's uid
    final snapshot = await _firestore
        .collection('companies')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // 3️⃣ Get user data from users subcollection
    final companyDoc = snapshot.docs.first;
    final companyCode = companyDoc.id;
    
    final userSnapshot = await _firestore
        .collection('companies')
        .doc(companyCode)
        .collection('users')
        .doc(uid)
        .get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      
      // 4️⃣ Save to cache
      await CacheService.saveLoginData(
        companyCode: companyCode,
        email: userData?['email'] ?? email,
        name: userData?['name'] ?? 'Admin',
        role: userData?['role'] ?? 'admin',
      );
    }

    // 5️⃣ Return the first matching company
    return Company.fromMap(companyDoc.data(), companyDoc.id);
  }

  static Future<bool> checkAnyCompanyExists() async {
    final snapshot = await _firestore.collection('companies').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  static Future<void> logout() async {
    await _auth.signOut();
    await CacheService.clearLoginData();
  }

  // 🔹 Check authentication state
  static Future<Map<String, dynamic>?> getCurrentAuthState() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final cachedData = await CacheService.getLoginData();
    return {
      'uid': user.uid,
      'email': user.email,
      'companyCode': cachedData['companyCode'],
      'name': cachedData['name'],
      'role': cachedData['role'],
      'isLoggedIn': true,
    };
  }
}