
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/models/clinic.dart';
import 'package:tech_care/features/account/clinic_edit_profile_page.dart';

// --- TRANG HIỂN THỊ HỒ SƠ PHÒNG KHÁM ---
class ClinicAccountPage extends StatelessWidget {
  const ClinicAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Hồ sơ Phòng khám"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clinics').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("Chưa có dữ liệu"));

          final clinic = Clinic.fromFirestore(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Ảnh bìa/Logo
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.teal[100],
                  child: clinic.imageUrl.isNotEmpty
                      ? Image.network(clinic.imageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.local_hospital, size: 80, color: Colors.teal),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(clinic.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () => Get.to(() => ClinicEditProfilePage(uid: user.uid, clinic: clinic)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(clinic.address))]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.phone, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(clinic.hotline)]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 4), Text("Giờ mở cửa: ${clinic.openHours}")]),
                      
                      const SizedBox(height: 20),
                      const Text("Giới thiệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(clinic.description.isEmpty ? "Chưa có mô tả" : clinic.description),

                      const SizedBox(height: 20),
                      const Text("Dịch vụ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: clinic.services.map((s) => Chip(label: Text(s), backgroundColor: Colors.teal[50])).toList(),
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async { await FirebaseAuth.instance.signOut(); Get.offAll(() => const Login()); },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
