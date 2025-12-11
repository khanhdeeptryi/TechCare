// File: lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// User model - Thông tin chung của user trong hệ thống
class UserModel {
  final String uid;
  final String email;
  final String role; // 'patient' hoặc 'doctor'
  final Timestamp createdAt;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
  });

  /// Tạo từ Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'patient',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      displayName: data['displayName']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
    );
  }

  /// Convert sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'createdAt': createdAt,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  /// Check xem user có phải là doctor không
  bool get isDoctor => role == 'doctor';

  /// Check xem user có phải là patient không
  bool get isPatient => role == 'patient';

  /// Copy with
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    Timestamp? createdAt,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
