// File: lib/wrapper_enhanced.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'features/authenticate/login.dart';
import 'features/doctor/doctor_main_screen.dart';
import 'features/patient/patient_main_screen.dart';

/// WrapperEnhanced - Wrapper với role-based navigation
/// Kiểm tra authentication và điều hướng dựa trên role
class WrapperEnhanced extends StatelessWidget {
  const WrapperEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang kiểm tra authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Chưa đăng nhập -> Login
        if (!snapshot.hasData || snapshot.data == null) {
          return const Login();
        }

        // Đã đăng nhập -> Check role và navigate
        return RoleNavigator(user: snapshot.data!);
      },
    );
  }
}

/// RoleNavigator - Widget kiểm tra role và điều hướng
class RoleNavigator extends StatelessWidget {
  final User user;

  const RoleNavigator({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<String?>(
      future: authService.getUserRole(user.uid),
      builder: (context, snapshot) {
        // Đang load role
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải thông tin...'),
                ],
              ),
            ),
          );
        }

        // Có lỗi hoặc không có role
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải thông tin người dùng',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      }
                    },
                    child: const Text('Đăng nhập lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final role = snapshot.data!;

        // Navigate dựa trên role
        if (role == 'doctor') {
          return const DoctorMainScreen();
        } else {
          // Default: patient
          return const PatientMainScreen();
        }
      },
    );
  }
}
