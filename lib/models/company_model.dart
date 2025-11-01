// models/company_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String password;
  final String companyName;
  final String email;
  final String phone;
  final String? altPhone;
  final String state;
  final String district;
  final String address;
  final String? description;
  final String companyCode;
  final DateTime createdAt;

  Company({
    required this.password,
    required this.companyName,
    required this.email,
    required this.phone,
    this.altPhone,
    required this.state,
    required this.district,
    required this.address,
    this.description,
    required this.companyCode,
    required this.createdAt,
  });

  // Convert Company object to Map
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'altPhone': altPhone,
      'state': state,
      'district': district,
      'address': address,
      'description': description,
      'companyCode': companyCode,
      'createdAt': createdAt,
    };
  }

  // Create Company object from Map
  factory Company.fromMap(Map<String, dynamic> map, String companyCode) {
    return Company(
      password: map['password'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      altPhone: map['altPhone'],
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      address: map['address'] ?? '',
      description: map['description'],
      companyCode: companyCode,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  Company copyWith({
    String? password,
    String? companyName,
    String? email,
    String? phone,
    String? altPhone,
    String? state,
    String? district,
    String? address,
    String? description,
    String? companyCode,
    DateTime? createdAt,
  }) {
    return Company(
      password: password ?? this.password,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      state: state ?? this.state,
      district: district ?? this.district,
      address: address ?? this.address,
      description: description ?? this.description,
      companyCode: companyCode ?? this.companyCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}