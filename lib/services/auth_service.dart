// File: lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/doctor.dart';

/// AuthService - Service xử lý authentication và user management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Stream current user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng ký Patient
  Future<User?> signUpPatient({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Tạo user trong Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Update display name nếu có
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      // Tạo document trong collection 'users'
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        role: 'patient',
        createdAt: Timestamp.now(),
        displayName: displayName,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng ký Doctor
  Future<User?> signUpDoctor({
    required String email,
    required String password,
    required String name,
    required String specialty,
    required String hospital,
    String? phone,
    String? bio,
  }) async {
    try {
      // Tạo user trong Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Update display name
      await user.updateDisplayName(name);

      // Tạo document trong collection 'users'
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        role: 'doctor',
        createdAt: Timestamp.now(),
        displayName: name,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      // QUAN TRỌNG: Tạo document trong collection 'doctors'
      final doctor = Doctor(
        id: user.uid, // Dùng chung uid với Auth
        name: name,
        title: 'Dr.', // Mặc định
        experience: 0, // Sẽ cập nhật sau
        address: hospital,
        imageUrl: '', // Sẽ cập nhật sau
        specialties: [specialty],
        bio: bio ?? '',
        hospital: hospital,
        phone: phone,
        email: email,
        isVerified: false, // Chờ admin xác thực
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('doctors').doc(user.uid).set(doctor.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Lấy thông tin user từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  /// Lấy thông tin doctor từ Firestore
  Future<Doctor?> getDoctorData(String uid) async {
    try {
      final doc = await _firestore.collection('doctors').doc(uid).get();
      if (!doc.exists) return null;
      return Doctor.fromFirestore(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  /// Check role và trả về 'patient' hoặc 'doctor'
  Future<String?> getUserRole(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?.role;
    } catch (e) {
      return null;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) return;

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  /// Update doctor profile
  Future<void> updateDoctorProfile(Doctor doctor) async {
    await _firestore
        .collection('doctors')
        .doc(doctor.id)
        .update(doctor.toMap());
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;

    // Xóa data từ Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Nếu là doctor, xóa luôn document trong doctors
    final userData = await getUserData(user.uid);
    if (userData?.isDoctor == true) {
      await _firestore.collection('doctors').doc(user.uid).delete();
    }

    // Xóa user từ Firebase Auth
    await user.delete();
  }
}
