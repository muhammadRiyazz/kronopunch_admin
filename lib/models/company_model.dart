import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String? id;
  final String companyName;
  final String email;
  final String phone;
  final String? altPhone;
  final String state;
  final String district;
  final String address;
  final String? description;
  final String companyCode;
  final String password;
  final DateTime createdAt;

  Company({
    this.id,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.password,
    this.altPhone,
    required this.state,
    required this.district,
    required this.address,
    this.description,
    required this.companyCode,
    required this.createdAt,
  });
Company copyWith({
  String? companyName,
  String? email,
  String? phone,
  String? altPhone,
  String? state,
  String? district,
  String? address,
  String? description,
  String? companyCode,
  String? password,
  DateTime? createdAt,
}) {
  return Company(
    password: password??this.password,
    id: id,
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

  Map<String, dynamic> toMap() {
    return {
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
      'password':password
    };
  }

  static Company fromMap(Map<String, dynamic> map, String id) {
    return Company(
      password: map['password']??'',
      id: id,
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      altPhone: map['altPhone'],
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      address: map['address'] ?? '',
      description: map['description'],
      companyCode: map['companyCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}