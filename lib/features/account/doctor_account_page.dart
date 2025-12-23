import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/models/doctor.dart'; // Import model Doctor
import 'package:tech_care/features/account/doctor_edit_profile_page.dart'; // Import trang sửa (xem Bước 3)

class DoctorAccountPage extends StatelessWidget {
  const DoctorAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    // Giả sử thông tin bác sĩ lưu trong collection 'doctors' với ID trùng User UID
    // Nếu bạn lưu trong 'users' và có field role='doctor', hãy đổi tên collection
    final docRef = FirebaseFirestore.instance.collection('doctors').doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Hồ sơ Bác sĩ"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Mở cài đặt chung nếu cần
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có thông tin hồ sơ bác sĩ."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Get.to(() => DoctorEditProfilePage(docId: user.uid)),
                    child: const Text("Tạo hồ sơ ngay"),
                  )
                ],
              ),
            );
          }

          // Convert dữ liệu sang Model Doctor
          final doctorData = snapshot.data!.data() as Map<String, dynamic>;
          final doctor = Doctor.fromFirestore(doctorData, snapshot.data!.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                _buildHeader(doctor),
                const SizedBox(height: 16),
                _buildStats(doctor),
                const SizedBox(height: 16),
                _buildInfoSection(doctor),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. Header (Avatar, Tên, Chức danh)
  Widget _buildHeader(Doctor doctor) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[50],
                backgroundImage: doctor.imageUrl.isNotEmpty
                    ? NetworkImage(doctor.imageUrl)
                    : null,
                child: doctor.imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.blue)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => DoctorEditProfilePage(docId: doctor.id, doctor: doctor)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doctor.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.title.toUpperCase(),
            style: TextStyle(fontSize: 14, color: Colors.blue[800], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // 2. Thống kê (Kinh nghiệm)
  Widget _buildStats(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(doctor.experience.toString(), "Năm kinh nghiệm"),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _statItem("${doctor.specialties.length}", "Chuyên khoa"),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _statItem("4.8", "Đánh giá"), // Giả lập đánh giá
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // 3. Thông tin chi tiết (Chuyên khoa, Bio, Địa chỉ)
  Widget _buildInfoSection(Doctor doctor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chuyên khoa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.specialties.map((s) => Chip(
              label: Text(s),
              backgroundColor: Colors.blue[50],
              labelStyle: TextStyle(color: Colors.blue[800]),
              side: BorderSide.none,
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          const Text("Giới thiệu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(doctor.bio, style: const TextStyle(height: 1.5, color: Colors.black87)),
          ),

          const SizedBox(height: 20),
          const Text("Nơi công tác", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(doctor.address)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Nút Đăng xuất
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offAll(() => const Login());
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}