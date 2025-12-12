import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart'; // Import model của bạn

class HealthProfilePage extends StatelessWidget {
  const HealthProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Query: Lấy lịch hẹn của User này VÀ trạng thái là 'completed'
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user?.uid)
        .where('status', isEqualTo: 'completed') // Chỉ lấy ca đã khám xong
        .orderBy('appointmentTime', descending: true); // Mới nhất lên đầu

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ sức khỏe"),
        backgroundColor: Colors.blue,
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
            return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa có hồ sơ khám bệnh nào.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final appointment = Appointment.fromFirestore(data, docs[index].id);

              return _buildRecordCard(context, appointment);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, Appointment appointment) {
    // Format ngày tháng: 12/12/2025
    final dateStr = DateFormat('dd/MM/yyyy').format(appointment.appointmentTime.toDate());
    
    // Lấy thông tin kết quả khám (nếu có)
    final diagnosis = appointment.examinationResult?.diagnosis ?? "Chưa có chẩn đoán";
    final doctorName = appointment.doctorInfo['name'] ?? "Bác sĩ";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Khi bấm vào thì xem chi tiết (Logic xem chi tiết ở Bước 1.1 bên dưới)
          Get.to(() => MedicalRecordDetailScreen(appointment: appointment));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateStr,
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                diagnosis.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("BS. $doctorName", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- BƯỚC 1.1: Màn hình chi tiết (Xem đơn thuốc, lời dặn...) ---
class MedicalRecordDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const MedicalRecordDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final result = appointment.examinationResult;
    if (result == null) return const Scaffold(body: Center(child: Text("Lỗi dữ liệu")));

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết khám bệnh"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Chẩn đoán", result.diagnosis, Icons.local_hospital, Colors.red),
            _buildSection("Triệu chứng", result.symptoms, Icons.sick, Colors.orange),
            _buildSection("Lời dặn", result.doctorNotes, Icons.note, Colors.blue),
            
            const SizedBox(height: 20),
            const Text("Đơn thuốc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            if (result.prescription.isEmpty)
              const Text("Không có đơn thuốc", style: TextStyle(color: Colors.grey))
            else
              ...result.prescription.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.dosage} | ${item.frequency}\n${item.duration}"),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text(content.isEmpty ? "Không có thông tin" : content, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}