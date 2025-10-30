import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseEmployeeService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  // Get company code for current user
  static Future<String?> _getCompanyCode() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('companies')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (userDoc.docs.isEmpty) return null;
    return userDoc.docs.first.id;
  }

  // Generate custom employee ID (empl_001, empl_002, etc.)
  static Future<String> _generateEmployeeId() async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      final employeesSnapshot = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .orderBy('employeeNumber', descending: true)
          .limit(1)
          .get();

      int nextNumber = 1;
      if (employeesSnapshot.docs.isNotEmpty) {
        final lastEmployee = employeesSnapshot.docs.first.data();
        final lastNumber = lastEmployee['employeeNumber'] ?? 0;
        nextNumber = lastNumber + 1;
      }

      return 'empl_${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      log('Error generating employee ID: $e');
      rethrow;
    }
  }

  // Load all employees
  static Future<List<Map<String, dynamic>>> loadEmployees() async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) return [];

      final employeesSnapshot = await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .orderBy('createdAt', descending: true)
          .get();

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
          'employeeId': data['employeeId'] ?? '',
          'employeeNumber': data['employeeNumber'] ?? 0,
          'role': data['role'] ?? 'Employee',
          'password': data['password'] ?? '',
          'avatar': data['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
          'status': data['status'] ?? 'Present',
          'createdAt': data['createdAt'],
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

      // Generate custom employee ID
      final employeeId = await _generateEmployeeId();
      final employeeNumber = int.parse(employeeId.split('_')[1]);

      final employeeDataWithId = {
        ...employeeData,
        'employeeId': employeeId,
        'employeeNumber': employeeNumber,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .add(employeeDataWithId);
    } catch (e) {
      log('Error adding employee: $e');
      rethrow;
    }
  }

  // Update employee
  static Future<void> updateEmployee(String employeeId, Map<String, dynamic> employeeData) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(employeeId)
          .update({
            ...employeeData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      log('Error updating employee: $e');
      rethrow;
    }
  }

  // Delete employee
  static Future<void> deleteEmployee(String employeeId) async {
    try {
      final companyCode = await _getCompanyCode();
      if (companyCode == null) throw Exception('Company not found');

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .doc(employeeId)
          .delete();
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

      return {
        'total': employees.length,
        'present': presentCount,
        'onLeave': onLeaveCount,
        'departments': departmentsCount,
      };
    } catch (e) {
      log('Error getting stats: $e');
      rethrow;
    }
  }
}