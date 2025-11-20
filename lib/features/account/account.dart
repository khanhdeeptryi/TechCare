import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/authenticate/login.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Header - Avatar, Name, Phone
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 35, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phạm Quốc Khánh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+84944284242',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Card 1 - Group 1
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.folder_open,
                      iconColor: Colors.blue,
                      title: 'Hồ sơ y tế',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      title: 'Danh sách quan tâm',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.error_outline,
                      iconColor: Colors.purple,
                      title: 'Điều khoản và quy định',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.group,
                      iconColor: Colors.green,
                      title: 'Tham gia cộng đồng',
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Card 2 - Group 2
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.share,
                      iconColor: Colors.pink,
                      title: 'Chia sẻ ứng dụng',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.headset_mic,
                      iconColor: Colors.cyan,
                      title: 'Liên hệ & hỗ trợ',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      iconColor: Colors.grey[800]!,
                      title: 'Cài đặt',
                      showDivider: true,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Đăng xuất',
                      showDivider: false,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Footer - Version info
              // Text(
              //   'Version 3.2.28 (2024300905) - Prod - PUBLISHED',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey[500],
              //   ),
              // ),
              
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 56),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
      ],
    );
  }
}
