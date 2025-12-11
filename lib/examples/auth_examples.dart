// File: lib/examples/auth_examples.dart
// Ví dụ sử dụng hệ thống Authentication

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/doctor.dart';

/// ============================================
/// EXAMPLE 1: Đăng ký Patient
/// ============================================

class PatientSignupExample {
  final AuthService _authService = AuthService();

  Future<void> registerPatient(
    String email,
    String password,
    String name,
  ) async {
    try {
      final user = await _authService.signUpPatient(
        email: email,
        password: password,
        displayName: name,
      );

      if (user != null) {
        print('✅ Đăng ký patient thành công: ${user.uid}');

        // Lấy thông tin user từ Firestore
        final userData = await _authService.getUserData(user.uid);
        print('Role: ${userData?.role}'); // Output: patient
        print('Email: ${userData?.email}');
      }
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
    }
  }
}

/// ============================================
/// EXAMPLE 2: Đăng ký Doctor
/// ============================================

class DoctorSignupExample {
  final AuthService _authService = AuthService();

  Future<void> registerDoctor({
    required String email,
    required String password,
    required String name,
    required String specialty,
    required String hospital,
    String? phone,
    String? bio,
  }) async {
    try {
      final user = await _authService.signUpDoctor(
        email: email,
        password: password,
        name: name,
        specialty: specialty,
        hospital: hospital,
        phone: phone,
        bio: bio,
      );

      if (user != null) {
        print('✅ Đăng ký doctor thành công: ${user.uid}');

        // Lấy thông tin user
        final userData = await _authService.getUserData(user.uid);
        print('Role: ${userData?.role}'); // Output: doctor

        // Lấy thông tin doctor
        final doctorData = await _authService.getDoctorData(user.uid);
        print('Specialty: ${doctorData?.specialties}');
        print('Hospital: ${doctorData?.hospital}');
        print(
          'Verified: ${doctorData?.isVerified}',
        ); // Output: false (chờ admin verify)
      }
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
    }
  }
}

/// ============================================
/// EXAMPLE 3: Login và Check Role
/// ============================================

class LoginExample {
  final AuthService _authService = AuthService();

  Future<void> loginAndCheckRole(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Đăng nhập
      final user = await _authService.signIn(email: email, password: password);

      if (user != null) {
        print('✅ Đăng nhập thành công: ${user.uid}');

        // Check role
        final role = await _authService.getUserRole(user.uid);

        if (role == 'doctor') {
          print('👨‍⚕️ Điều hướng đến DoctorMainScreen');
          // Navigator.pushReplacement(context, ...DoctorMainScreen);
        } else {
          print('👤 Điều hướng đến PatientMainScreen');
          // Navigator.pushReplacement(context, ...PatientMainScreen);
        }
      }
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
    }
  }

  // Login với UI
  Widget buildLoginButton(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return ElevatedButton(
      onPressed: () async {
        await loginAndCheckRole(
          context,
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      },
      child: const Text('Đăng nhập'),
    );
  }
}

/// ============================================
/// EXAMPLE 4: Lấy thông tin User và Doctor
/// ============================================

class UserDataExample {
  final AuthService _authService = AuthService();

  // Lấy thông tin user hiện tại
  Future<void> getCurrentUserInfo() async {
    final user = _authService.currentUser;
    if (user == null) {
      print('❌ Chưa đăng nhập');
      return;
    }

    print('Current User ID: ${user.uid}');
    print('Email: ${user.email}');
    print('Display Name: ${user.displayName}');

    // Lấy từ Firestore
    final userData = await _authService.getUserData(user.uid);
    if (userData != null) {
      print('Role: ${userData.role}');
      print('Created At: ${userData.createdAt.toDate()}');
      print('Is Doctor: ${userData.isDoctor}');
      print('Is Patient: ${userData.isPatient}');
    }
  }

  // Lấy thông tin doctor (nếu là doctor)
  Future<void> getDoctorInfo(String doctorId) async {
    final doctorData = await _authService.getDoctorData(doctorId);

    if (doctorData != null) {
      print('Doctor Name: ${doctorData.name}');
      print('Specialties: ${doctorData.specialties.join(", ")}');
      print('Hospital: ${doctorData.hospital}');
      print('Experience: ${doctorData.experience} years');
      print('Verified: ${doctorData.isVerified}');
      print('Bio: ${doctorData.bio}');
    }
  }

  // Hiển thị thông tin user trong Widget
  Widget buildUserProfile(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _authService.getUserData(_authService.currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data;
        if (userData == null) {
          return const Text('Không tìm thấy thông tin user');
        }

        return Column(
          children: [
            Text('Email: ${userData.email}'),
            Text('Role: ${userData.role}'),
            Text('Display Name: ${userData.displayName ?? "N/A"}'),

            // Nếu là doctor, hiển thị thêm thông tin chuyên môn
            if (userData.isDoctor)
              FutureBuilder<Doctor?>(
                future: _authService.getDoctorData(userData.uid),
                builder: (context, doctorSnapshot) {
                  if (doctorSnapshot.hasData) {
                    final doctor = doctorSnapshot.data!;
                    return Column(
                      children: [
                        Text('Chuyên khoa: ${doctor.specialties.join(", ")}'),
                        Text('Bệnh viện: ${doctor.hospital ?? "N/A"}'),
                        Text('Kinh nghiệm: ${doctor.experience} năm'),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        );
      },
    );
  }
}

/// ============================================
/// EXAMPLE 5: Update Profile
/// ============================================

class ProfileUpdateExample {
  final AuthService _authService = AuthService();

  // Update user profile (name, photo)
  Future<void> updateUserProfile({String? newName, String? newPhotoUrl}) async {
    try {
      await _authService.updateUserProfile(
        displayName: newName,
        photoUrl: newPhotoUrl,
      );
      print('✅ Cập nhật profile thành công');
    } catch (e) {
      print('❌ Lỗi cập nhật: $e');
    }
  }

  // Update doctor profile
  Future<void> updateDoctorProfile({
    required String doctorId,
    String? newBio,
    int? newExperience,
    List<String>? newSpecialties,
  }) async {
    try {
      // Lấy data hiện tại
      final currentData = await _authService.getDoctorData(doctorId);
      if (currentData == null) return;

      // Tạo bản copy với dữ liệu mới
      final updatedDoctor = currentData.copyWith(
        bio: newBio,
        experience: newExperience,
        specialties: newSpecialties,
      );

      // Update
      await _authService.updateDoctorProfile(updatedDoctor);
      print('✅ Cập nhật thông tin bác sĩ thành công');
    } catch (e) {
      print('❌ Lỗi cập nhật: $e');
    }
  }
}

/// ============================================
/// EXAMPLE 6: Logout
/// ============================================

class LogoutExample {
  final AuthService _authService = AuthService();

  Future<void> logout(BuildContext context) async {
    try {
      await _authService.signOut();
      print('✅ Đăng xuất thành công');

      // Navigate to login screen
      // Navigator.pushReplacement(context, ...LoginScreen);
    } catch (e) {
      print('❌ Lỗi đăng xuất: $e');
    }
  }

  // Logout button với confirmation
  Widget buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await logout(context);
        }
      },
      child: const Text('Đăng xuất'),
    );
  }
}

/// ============================================
/// EXAMPLE 7: Complete Registration Flow
/// ============================================

class CompleteRegistrationFlow extends StatefulWidget {
  const CompleteRegistrationFlow({Key? key}) : super(key: key);

  @override
  State<CompleteRegistrationFlow> createState() =>
      _CompleteRegistrationFlowState();
}

class _CompleteRegistrationFlowState extends State<CompleteRegistrationFlow> {
  final AuthService _authService = AuthService();
  String _selectedRole = 'patient';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _hospitalController = TextEditingController();

  Future<void> _handleRegistration() async {
    try {
      if (_selectedRole == 'patient') {
        // Đăng ký patient
        final user = await _authService.signUpPatient(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
        );

        if (user != null) {
          print('✅ Patient registered: ${user.uid}');
          // Navigate to PatientMainScreen
        }
      } else {
        // Đăng ký doctor
        final user = await _authService.signUpDoctor(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          specialty: _specialtyController.text.trim(),
          hospital: _hospitalController.text.trim(),
        );

        if (user != null) {
          print('✅ Doctor registered: ${user.uid}');
          // Navigate to DoctorMainScreen
        }
      }
    } catch (e) {
      print('❌ Registration error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Role selection
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'patient', label: Text('Patient')),
                ButtonSegment(value: 'doctor', label: Text('Doctor')),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedRole = newSelection.first);
              },
            ),
            const SizedBox(height: 16),

            // Common fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            // Doctor-specific fields
            if (_selectedRole == 'doctor') ...[
              TextField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty'),
              ),
              TextField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital'),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRegistration,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _specialtyController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }
}
