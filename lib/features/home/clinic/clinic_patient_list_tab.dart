import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/home/medical_record/patient_medical_record_page.dart';

class ClinicPatientListTab extends StatelessWidget {
  const ClinicPatientListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('clinicId', isEqualTo: user?.uid); 

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

          // Lọc danh sách bệnh nhân duy nhất
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

          if (patientsList.isEmpty) {
             return const Center(child: Text("Chưa có bệnh nhân nào"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patientsList.length,
            itemBuilder: (context, index) {
              final patientData = patientsList[index];
              final profile = patientData['profile'];
              final String userId = patientData['userId'];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: const Icon(Icons.person, color: Colors.teal),
                  ),
                  title: Text(
                    profile['fullName'] ?? 'Ẩn danh', 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(profile['phoneNumber'] ?? 'Không có SĐT'),
                  trailing: const Icon(Icons.history, color: Colors.grey), // Icon biểu thị lịch sử
                  
                  // --- [SỰ KIỆN BẤM VÀO] ---
                  onTap: () {
                    Get.to(() => PatientMedicalRecordPage(
                      patientId: userId,
                      patientName: profile['fullName'] ?? 'Bệnh nhân',
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