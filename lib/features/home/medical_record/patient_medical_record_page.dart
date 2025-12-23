import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/features/health_profile/health_profile_page.dart'; // Để dùng lại MedicalRecordDetailScreen

class PatientMedicalRecordPage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const PatientMedicalRecordPage({super.key, required this.patientId, required this.patientName});

  @override
  Widget build(BuildContext context) {
    // Query lịch sử khám ĐÃ HOÀN THÀNH của bệnh nhân này
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentTime', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Hồ sơ: $patientName"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Bệnh nhân này chưa có lịch sử khám bệnh."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final appointment = Appointment.fromFirestore(data, docs[index].id);
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(appointment.appointmentTime.toDate());
              final diagnosis = appointment.examinationResult?.diagnosis ?? "Chưa có chẩn đoán";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.history_edu, color: Colors.green),
                  ),
                  title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Chẩn đoán: $diagnosis"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _rowDetail("Triệu chứng:", appointment.examinationResult?.symptoms ?? "--"),
                          const SizedBox(height: 8),
                          _rowDetail("Đơn thuốc:", appointment.examinationResult?.prescription.map((e) => e.name).join(", ") ?? "Không có"),
                          const SizedBox(height: 8),
                          _rowDetail("Lời dặn:", appointment.examinationResult?.doctorNotes ?? "--"),
                          const SizedBox(height: 10),
                          // Nút xem chi tiết đầy đủ
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.to(() => MedicalRecordDetailScreen(appointment: appointment));
                              },
                              child: const Text("Xem chi tiết đầy đủ"),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        Expanded(child: Text(value)),
      ],
    );
  }
}