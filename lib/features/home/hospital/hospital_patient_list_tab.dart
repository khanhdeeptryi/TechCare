import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/home/medical_record/patient_medical_record_page.dart';

class HospitalPatientListTab extends StatelessWidget {
  const HospitalPatientListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('hospitalId', isEqualTo: user?.uid); 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách bệnh nhân"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 0.5
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> uniquePatients = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['userId'] != null) {
              uniquePatients[data['userId']] = {
                'userId': data['userId'],
                'profile': data['patientProfile'] ?? {},
              };
            }
          }
          final patientsList = uniquePatients.values.toList();

          if (patientsList.isEmpty) return const Center(child: Text("Chưa có bệnh nhân nào"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patientsList.length,
            itemBuilder: (context, index) {
              final patientData = patientsList[index];
              final profile = patientData['profile'];
              final String userId = patientData['userId'];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(profile['fullName'] ?? 'Ẩn danh', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(profile['phoneNumber'] ?? 'Không có SĐT'),
                  trailing: const Icon(Icons.history, color: Colors.grey),
                  onTap: () {
                    // Chuyển sang màn hình lịch sử (Dùng chung PatientHistoryScreen)
                    // Lưu ý: PatientHistoryScreen cần nhận clinicId nhưng ở đây ta truyền hospitalId
                    // Bạn có thể sửa PatientHistoryScreen để nhận `providerId` chung chung
                    // Hoặc tạo file riêng nếu muốn tách biệt hoàn toàn.
                    // Ở đây tôi giả sử bạn dùng chung và truyền hospitalId vào tham số clinicId
                    Get.to(() => PatientMedicalRecordPage(
                      patientId: userId, 
                      patientName: profile['fullName'] ?? 'Bệnh nhân'
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