import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String? id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final String companyId;

  Employee({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.companyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'companyId': companyId,
    };
  }

  static Employee fromMap(Map<String, dynamic> map, String id) {
    return Employee(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      companyId: map['companyId'] ?? '',
    );
  }
}