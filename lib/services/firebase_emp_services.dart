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
          'role': data['role'] ?? 'Employee',
          'avatar': data['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
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

      await _firestore
          .collection('companies')
          .doc(companyCode)
          .collection('employees')
          .add(employeeData);
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
          .update(employeeData);
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