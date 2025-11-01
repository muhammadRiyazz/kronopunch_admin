// services/firebase_employee_service.dart
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'cache_service.dart';

class FirebaseEmployeeService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  // Get company code for current user - FIXED VERSION
  static Future<String?> _getCompanyCode() async {
    try {
      // Directly use cached company code (simplest and most reliable)
      final cachedData = await CacheService.getLoginData();
      final companyCode = cachedData['companyCode'];
      
      if (companyCode != null && companyCode.isNotEmpty) {
        log('✅ Using cached company code: $companyCode');
        return companyCode;
      }
      
      // Fallback: Query companies collection
      final user = _auth.currentUser;
      if (user == null) return null;

      final companySnapshot = await _firestore
          .collection('companies')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (companySnapshot.docs.isNotEmpty) {
        final foundCode = companySnapshot.docs.first.id;
        log('✅ Found company code from query: $foundCode');
        return foundCode;
      }

      log('❌ Company not found for user: ${user.uid}');
      return null;
    } catch (e) {
      log('Error getting company code: $e');
      return null;
    }
  }

  // Load all employees
  static Future<List<Map<String, dynamic>>> loadEmployees() async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) {
        log('❌ No company code found for loading employees');
        return [];
      }

      final employeesSnapshot = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .orderBy('createdAt', descending: true)
          .get();

      log('✅ Loaded ${employeesSnapshot.docs.length} employees from $companyCode');

      return employeesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'department': data['department'] ?? '',
          'position': data['position'] ?? '',
          'contact': data['contact'] ?? '',
          'email': data['email'] ?? '',
          'joiningDate': data['joiningDate'] ?? '',
          'place': data['place'] ?? '',
          'gender': data['gender'] ?? 'Male',
          'customEmployeeId': data['customEmployeeId'] ?? '', // User input ID
          'documentId': data['documentId'] ?? doc.id, // Auto-generated ID
          'role': data['role'] ?? 'Employee',
          'avatar': data['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
          'status': data['status'] ?? 'Present',
          'uid': data['uid'] ?? '',
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    } catch (e) {
      log('Error loading employees: $e');
      rethrow;
    }
  }

  // Add new employee
  static Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      log('✅ Adding employee to company: $companyCode');

      // Generate automatic document ID
      final String documentId = await _generateEmployeeDocumentId();
      log('✅ Generated document ID: $documentId');
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: employeeData['email'],
        password: employeeData['password'],
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('User creation failed');

      log('✅ Firebase Auth user created: $uid');

      // Prepare employee data for Firestore
      final employeeDataWithId = {
        ...employeeData,
        'uid': uid,
        'documentId': documentId, // Store the auto-generated document ID
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove password from stored data for security
      employeeDataWithId.remove('password');

      // Add to employees collection with auto-generated document ID
      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(documentId) // Use auto-generated ID as document ID
          .set(employeeDataWithId);

      log('✅ Employee document created: $documentId');

      // Also create a user document in the users collection
      final userData = <String, dynamic>{
        'uid': uid,
        'email': employeeData['email'],
        'name': employeeData['name'],
        'role': employeeData['role'],
        'companyCode': companyCode,
        'employeeDocumentId': documentId,
        'customEmployeeId': employeeData['customEmployeeId'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('users')
          .doc(uid)
          .set(userData);

      log('✅ User document created for employee');

      // Update company's users array
      await _firestore
          .collection('companies')
          .doc(companyCode)
          .update({
            'users': FieldValue.arrayUnion([uid])
          });

      log('🎉 Employee added successfully: ${employeeData['name']} ($documentId)');

    } catch (e) {
      log('Error adding employee: $e');
      rethrow;
    }
  }

  // Generate automatic document ID like empl001, empl002, etc.
  static Future<String> _generateEmployeeDocumentId() async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      final employeesSnapshot = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      int nextNumber = 1;
      if (employeesSnapshot.docs.isNotEmpty) {
        // Get the last document ID and extract the number
        final lastDoc = employeesSnapshot.docs.first;
        final lastDocId = lastDoc.id;
        
        if (lastDocId.startsWith('empl')) {
          final numberPart = lastDocId.replaceAll('empl', '');
          final lastNumber = int.tryParse(numberPart) ?? 0;
          nextNumber = lastNumber + 1;
          log('✅ Last employee number: $lastNumber, next: $nextNumber');
        } else {
          // If no empl IDs found, count existing documents
          final countSnapshot = await _firestore
              .collection('companies')
              .doc(companyCode)
              .collection('employees')
              .count()
              .get();
          nextNumber = (countSnapshot.count ?? 0) + 1;
          log('✅ Total employees: ${countSnapshot.count}, next: $nextNumber');
        }
      } else {
        log('✅ No existing employees, starting from 1');
      }

      final newId = 'empl${nextNumber.toString().padLeft(3, '0')}';
      log('✅ Generated new employee ID: $newId');
      return newId;
    } catch (e) {
      log('Error generating employee document ID: $e');
      rethrow;
    }
  }

  // Update employee
  static Future<void> updateEmployee(String documentId, Map<String, dynamic> employeeData) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      // Remove password if present for security
      final updatedData = Map<String, dynamic>.from(employeeData);
      updatedData.remove('password');

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(documentId)
          .update({
            ...updatedData,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      log('✅ Employee updated: $documentId');

      // Also update user document if email or name changed
      if (updatedData.containsKey('email') || updatedData.containsKey('name') || updatedData.containsKey('role')) {
        final employeeDoc = await _firestore
            .collection('companies')
            .doc(companyCode)
            .collection('employees')
            .doc(documentId)
            .get();

        final uid = employeeDoc.data()?['uid'];
        if (uid != null) {
          final userUpdateData = <String, dynamic>{};
          if (updatedData.containsKey('email')) userUpdateData['email'] = updatedData['email'];
          if (updatedData.containsKey('name')) userUpdateData['name'] = updatedData['name'];
          if (updatedData.containsKey('role')) userUpdateData['role'] = updatedData['role'];
          if (updatedData.containsKey('customEmployeeId')) userUpdateData['customEmployeeId'] = updatedData['customEmployeeId'];

          if (userUpdateData.isNotEmpty) {
            await _firestore
                .collection('companies')
                .doc(companyCode)
                .collection('users')
                .doc(uid)
                .update(userUpdateData);
            log('✅ User document updated for employee: $documentId');
          }
        }
      }

    } catch (e) {
      log('Error updating employee: $e');
      rethrow;
    }
  }

  // Delete employee
  static Future<void> deleteEmployee(String documentId) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      // Get employee data to find UID for user deletion
      final employeeDoc = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(documentId)
          .get();

      final employeeData = employeeDoc.data();
      final uid = employeeData?['uid'];
      final email = employeeData?['email'];

      // Delete employee document
      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(documentId)
          .delete();

      log('✅ Employee document deleted: $documentId');

      // Delete user document
      if (uid != null) {
        await _firestore
            .collection('companies')
            .doc(companyCode)
            .collection('users')
            .doc(uid)
            .delete();
        log('✅ User document deleted: $uid');

        // Remove from company's users array
        await _firestore
            .collection('companies')
            .doc(companyCode)
            .update({
              'users': FieldValue.arrayRemove([uid])
            });
      }

      // Note: Firebase Auth user deletion requires Admin SDK
      // For client-side, you might want to disable instead of delete
      if (email != null) {
        log('ℹ️ Firebase Auth user deletion requires Admin SDK: $email');
      }

      log('🎉 Employee deleted successfully: $documentId');

    } catch (e) {
      log('Error deleting employee: $e');
      rethrow;
    }
  }

  // Upload image to Firebase Storage
  static Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      final Reference storageRef = _storage
          .ref()
          .child('companies/$companyCode/employees/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    }
  }

  // Get employee statistics
  static Future<Map<String, int>> getEmployeeStats() async {
    try {
      final employees = await loadEmployees();
      final presentCount = employees.where((e) => e['status'] == 'Present').length;
      final onLeaveCount = employees.where((e) => e['status'] == 'On Leave').length;
      final departmentsCount = employees.map((e) => e['department']).toSet().length;

      final stats = {
        'total': employees.length,
        'present': presentCount,
        'onLeave': onLeaveCount,
        'departments': departmentsCount,
      };

      log('✅ Employee stats: $stats');
      return stats;
    } catch (e) {
      log('Error getting stats: $e');
      rethrow;
    }
  }

  // Get employee by document ID
  static Future<Map<String, dynamic>?> getEmployeeById(String documentId) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) return null;

      final doc = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(documentId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'department': data['department'] ?? '',
        'position': data['position'] ?? '',
        'contact': data['contact'] ?? '',
        'email': data['email'] ?? '',
        'joiningDate': data['joiningDate'] ?? '',
        'place': data['place'] ?? '',
        'gender': data['gender'] ?? 'Male',
        'customEmployeeId': data['customEmployeeId'] ?? '',
        'documentId': data['documentId'] ?? doc.id,
        'role': data['role'] ?? 'Employee',
        'avatar': data['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
        'status': data['status'] ?? 'Present',
        'uid': data['uid'] ?? '',
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      };
    } catch (e) {
      log('Error getting employee by ID: $e');
      return null;
    }
  }

  // Search employees
  static Future<List<Map<String, dynamic>>> searchEmployees(String query) async {
    try {
      final allEmployees = await loadEmployees();
      final lowerQuery = query.toLowerCase();
      
      return allEmployees.where((employee) {
        return employee['name'].toLowerCase().contains(lowerQuery) ||
               employee['email'].toLowerCase().contains(lowerQuery) ||
               employee['department'].toLowerCase().contains(lowerQuery) ||
               employee['position'].toLowerCase().contains(lowerQuery) ||
               (employee['customEmployeeId']?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      log('Error searching employees: $e');
      return [];
    }
  }
}