// File: lib/features/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../authenticate/login.dart';

/// AccountScreen - Màn hình tài khoản
class AccountScreen extends StatelessWidget {
  final bool isDoctor;

  const AccountScreen({Key? key, required this.isDoctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<UserModel?>(
        future: authService.getUserData(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[200],
                  child: Icon(
                    isDoctor ? Icons.medical_services : Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  user.displayName ?? userData?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  user.email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDoctor ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDoctor ? 'Bác sĩ' : 'Bệnh nhân',
                    style: TextStyle(
                      color: isDoctor ? Colors.blue[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Menu items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Thông tin cá nhân',
                  onTap: () {
                    // TODO: Navigate to profile edit
                  },
                ),
                if (isDoctor)
                  _buildMenuItem(
                    icon: Icons.medical_information_outlined,
                    title: 'Thông tin chuyên môn',
                    onTap: () {
                      // TODO: Navigate to doctor info edit
                    },
                  ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () {
                    // TODO: Change password
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo',
                  onTap: () {
                    // TODO: Notification settings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Trợ giúp',
                  onTap: () {
                    // TODO: Help center
                  },
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  color: Colors.red,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text(
                          'Bạn có chắc muốn đăng xuất không?',
                        ),
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
                      await authService.signOut();
                      Get.offAll(() => const Login());
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue[600]),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
