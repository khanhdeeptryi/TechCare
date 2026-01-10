import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/models/hospital.dart';
import 'package:tech_care/features/account/hospital_edit_profile_page.dart';

// --- TRANG HIỂN THỊ HỒ SƠ BỆNH VIỆN ---
class HospitalAccountPage extends StatelessWidget {
  const HospitalAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Hồ sơ Bệnh viện"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("Chưa có dữ liệu"));

          final hospital = Hospital.fromFirestore(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.indigo[100],
                  child: hospital.imageUrl.isNotEmpty
                      ? Image.network(hospital.imageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.apartment, size: 80, color: Colors.indigo),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(hospital.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () => Get.to(() => HospitalEditProfilePage(uid: user.uid, hospital: hospital)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(hospital.address))]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.phone, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(hospital.hotline)]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.language, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(hospital.website.isEmpty ? "Chưa cập nhật web" : hospital.website)]),
                      
                      const SizedBox(height: 20),
                      const Text("Giới thiệu chung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(hospital.description.isEmpty ? "Chưa có mô tả" : hospital.description),

                      const SizedBox(height: 20),
                      const Text("Chuyên khoa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: hospital.departments.map((s) => Chip(label: Text(s), backgroundColor: Colors.indigo[50])).toList(),
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
