import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/account/update_personal_info_page.dart';
// Import các trang liên kết
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
              const SizedBox(height: 20),

              // --- 1. HEADER: Lấy dữ liệu thật từ Firestore ---
              if (user != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Giá trị mặc định nếu chưa tải xong
                    String displayName = user.displayName ?? user.email ?? 'Người dùng';
                    String phoneNumber = user.phoneNumber ?? 'Chưa cập nhật SĐT';
                    String? avatarUrl;

                    // Nếu có dữ liệu từ Firestore, ưu tiên dùng dữ liệu đó
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      displayName = data['fullName'] ?? data['name'] ?? displayName;
                      phoneNumber = data['phoneNumber'] ?? data['phone'] ?? phoneNumber;
                      avatarUrl = data['avatarUrl'];
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
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
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Tên và SĐT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  phoneNumber,
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
                    );
                  },
                )
              else
                // Trường hợp chưa đăng nhập (hiện nút đăng nhập)
                GestureDetector(
                  onTap: () => Get.to(() => const Login()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Đăng nhập ngay",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // --- 2. MENU NHÓM 1 ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.folder_open, // Hoặc đổi icon thành Icons.person_outline
                      iconColor: Colors.blue,
                      title: 'Hồ sơ y tế (Thông tin cá nhân)', // Đổi tiêu đề cho rõ nghĩa nếu muốn
                      showDivider: true,
                      onTap: () {
                        if (user == null) {
                            Get.to(() => const Login());
                        } else {
                            Get.to(() => const UpdatePersonalInfoPage()); 
                        }
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      title: 'Danh sách quan tâm',
                      showDivider: true,
                      onTap: () {
                         Get.snackbar("Thông báo", "Chức năng đang phát triển");
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.error_outline,
                      iconColor: Colors.purple,
                      title: 'Điều khoản và quy định',
                      showDivider: true,
                      onTap: () {
                         Get.snackbar("Thông báo", "Chức năng đang phát triển");
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.group,
                      iconColor: Colors.green,
                      title: 'Tham gia cộng đồng',
                      showDivider: false,
                      onTap: () {
                         Get.snackbar("Thông báo", "Chức năng đang phát triển");
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- 3. MENU NHÓM 2 ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.share,
                      iconColor: Colors.pink,
                      title: 'Chia sẻ ứng dụng',
                      showDivider: true,
                      onTap: () {
                        // Thay vì dùng thư viện share, chỉ hiện thông báo
                        Get.snackbar("Chia sẻ", "Cảm ơn bạn đã muốn chia sẻ ứng dụng TechCare!");
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.headset_mic,
                      iconColor: Colors.cyan,
                      title: 'Liên hệ & hỗ trợ',
                      showDivider: true,
                      onTap: () {
                        // Thay vì gọi điện, hiện popup thông tin
                        Get.defaultDialog(
                          title: "Tổng đài hỗ trợ",
                          middleText: "Vui lòng gọi hotline: 1900 1234",
                          textConfirm: "Đóng",
                          confirmTextColor: Colors.white,
                          onConfirm: () => Get.back(),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      iconColor: Colors.grey[800]!,
                      title: 'Cài đặt',
                      showDivider: true,
                      onTap: () {
                         Get.snackbar("Thông báo", "Chức năng đang phát triển");
                      },
                    ),
                    
                    // Nút Đăng xuất (Chỉ hiện khi đã đăng nhập)
                    if (user != null)
                      _buildMenuItem(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        title: 'Đăng xuất',
                        showDivider: false,
                        onTap: () async {
                          // Đăng xuất và xóa hết lịch sử trang để về màn hình Login
                          await FirebaseAuth.instance.signOut();
                          Get.offAll(() => const Login()); 
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng từng dòng menu
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
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
            padding: const EdgeInsets.only(left: 56),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
      ],
    );
  }
}