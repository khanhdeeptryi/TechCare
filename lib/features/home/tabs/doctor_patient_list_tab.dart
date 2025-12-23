import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../medical_record/patient_medical_record_page.dart';

class DoctorPatientListTab extends StatelessWidget {
  const DoctorPatientListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Lấy ngày hôm nay
    final now = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 0, 0, 0));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user?.uid)
        .where('appointmentTime', isGreaterThanOrEqualTo: startOfDay)
        .where('appointmentTime', isLessThanOrEqualTo: endOfDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bệnh nhân hôm nay"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Hôm nay chưa có bệnh nhân nào đặt lịch"),
                ],
              ),
            );
          }

          // Lọc trùng bệnh nhân (nếu 1 người đặt 2 lịch trong ngày)
          final docs = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> uniquePatients = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'];
            if (userId != null) {
              uniquePatients[userId] = {
                'userId': userId,
                'profile': data['patientProfile'] ?? {},
              };
            }
          }

          final patientsList = uniquePatients.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patientsList.length,
            itemBuilder: (context, index) {
              final patientData = patientsList[index];
              final profile = patientData['profile'];
              final String name = profile['fullName'] ?? profile['name'] ?? 'Ẩn danh';
              final String phone = profile['phoneNumber'] ?? profile['phone'] ?? 'Không có SĐT';
              final String? avatarUrl = profile['avatarUrl'];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue[50],
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                      ? NetworkImage(avatarUrl) 
                      : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty) 
                      ? const Icon(Icons.person, color: Colors.blue) 
                      : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(phone, style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.assignment_ind, color: Colors.blue),
                  onTap: () {
                    // Xem hồ sơ bệnh án của bệnh nhân này
                    Get.to(() => PatientMedicalRecordPage(
                      patientId: patientData['userId'],
                      patientName: name,
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}