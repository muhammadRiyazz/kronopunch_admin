// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/company_model.dart';
import 'cache_service.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // 🔹 Register new company (Auth + Company Code)
  static Future<void> registerCompany({
    required String email,
    required Company company,
  }) async {
    try {
      debugPrint('🔄 Starting company registration for: $email');
      
      // 🔹 1. Create Firebase Auth user (Admin)
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: company.password,
      );

      final uid = userCredential.user?.uid;
      debugPrint('✅ Firebase Auth user created: $uid');

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

      debugPrint('🏢 Generated company code: $nextCompanyCode');

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

      debugPrint('✅ Company document created: $nextCompanyCode');

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
      debugPrint('✅ Admin user created in subcollection');

      // 🔹 5. Save to cache
      await CacheService.saveLoginData(
        companyCode: nextCompanyCode,
        email: email,
        name: '${company.companyName} Admin',
        role: 'admin',
      );

      debugPrint("🎉 Company Registered ($nextCompanyCode) with Admin User ($uid)");
    } catch (e) {
      debugPrint('❌ Company registration failed: $e');
      rethrow;
    }
  }

// services/firebase_service.dart - Update loginCompany method
static Future<Company?> loginCompany({
  required String email,
  required String password,
}) async {
  try {
    debugPrint('🔄 Starting login for: $email');
    
    // 1️⃣ Firebase Auth sign in
    UserCredential userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCred.user!.uid;
    debugPrint('✅ Firebase Auth sign in successful: $uid');

    // 2️⃣ Fetch company where uid == this user's uid
    final snapshot = await _firestore
        .collection('companies')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      debugPrint('❌ No company found for user: $uid');
      return null;
    }

    // 3️⃣ Get user data from users subcollection
    final companyDoc = snapshot.docs.first;
    final companyCode = companyDoc.id;
    debugPrint('🏢 Found company: $companyCode');
    
    final userSnapshot = await _firestore
        .collection('companies')
        .doc(companyCode)
        .collection('users')
        .doc(uid)
        .get();

    String userName = 'Admin';
    String userRole = 'admin';

    if (userSnapshot.exists) {
      final userData = userSnapshot.data()!;
      // FIXED: Proper type casting
      userName = (userData['name'] as String?) ?? 'Admin';
      userRole = (userData['role'] as String?) ?? 'admin';
      debugPrint('✅ User data found: $userName ($userRole)');
    } else {
      debugPrint('⚠️ User subcollection not found, using defaults');
    }

    // 4️⃣ Save to cache
    await CacheService.saveLoginData(
      companyCode: companyCode,
      email: email,
      name: userName,
      role: userRole,
    );

    debugPrint('✅ Login data saved to cache');

    // 5️⃣ Return the first matching company
    return Company.fromMap(companyDoc.data(), companyDoc.id);
  } catch (e) {
    debugPrint('❌ Login failed: $e');
    rethrow;
  }
}
  static Future<bool> checkAnyCompanyExists() async {
    try {
      final snapshot = await _firestore.collection('companies').limit(1).get();
      final exists = snapshot.docs.isNotEmpty;
      debugPrint('🏢 Company exists check: $exists');
      return exists;
    } catch (e) {
      debugPrint('❌ Company exists check failed: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      debugPrint('🔄 Starting logout process');
      await _auth.signOut();
      await CacheService.clearLoginData();
      debugPrint('✅ Logout completed successfully');
    } catch (e) {
      debugPrint('❌ Logout failed: $e');
      rethrow;
    }
  }

  // 🔹 Check authentication state
  static Future<Map<String, dynamic>?> getCurrentAuthState() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('🔐 No user logged in');
        return null;
      }

      final cachedData = await CacheService.getLoginData();
      final authState = {
        'uid': user.uid,
        'email': user.email,
        'companyCode': cachedData['companyCode'],
        'name': cachedData['name'],
        'role': cachedData['role'],
        'isLoggedIn': true,
      };
      
      debugPrint('🔐 Current auth state: ${authState['name']} (${authState['companyCode']})');
      return authState;
    } catch (e) {
      debugPrint('❌ Error getting auth state: $e');
      return null;
    }
  }
}