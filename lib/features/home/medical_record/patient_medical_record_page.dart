import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/features/appointments/medical_record_detail_screen.dart'; // Import đúng file chi tiết

class PatientMedicalRecordPage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const PatientMedicalRecordPage({
    super.key, 
    required this.patientId, 
    required this.patientName
  });

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
          
          if (snapshot.hasError) {
             return Center(child: Text("Lỗi: ${snapshot.error}"));
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
              // Parse dữ liệu bằng Model mới (có fallback)
              final appointment = Appointment.fromFirestore(data, docs[index].id);
              
              final date = appointment.appointmentTime.toDate();
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
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
                  subtitle: Text("Chẩn đoán: $diagnosis", maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          
                          // Nút xem chi tiết đầy đủ (Ảnh, tên bác sĩ...)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // --- SỬA LỖI TẠI ĐÂY ---
                                // Bỏ dấu "() =>" đi, truyền trực tiếp Widget vào
                                Get.to(MedicalRecordDetailScreen(appointment: appointment));
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text("Xem chi tiết đầy đủ"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue[800],
                                elevation: 0
                              ),
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
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}