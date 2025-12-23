import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/features/chat/chat_screen.dart';
import 'package:tech_care/features/examination/examination_screen.dart';

class AppointmentListWidget extends StatelessWidget {
  final DateTime selectedDate;

  const AppointmentListWidget({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final startOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0));
    final endOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));

    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user?.uid)
        .where('appointmentTime', isGreaterThanOrEqualTo: startOfDay)
        .where('appointmentTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('appointmentTime', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text('Không có lịch hẹn ngày ${DateFormat('dd/MM').format(selectedDate)}',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final appointment = Appointment.fromFirestore(data, docs[index].id);
            return _buildAppointmentItem(appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    final patientName = appointment.patientProfile['fullName'] ?? appointment.patientProfile['name'] ?? 'Bệnh nhân ẩn danh';
    final avatarUrl = appointment.patientProfile['avatarUrl'];

    String statusText;
    Color statusTextColor;
    switch (appointment.status) {
      case 'confirmed': statusText = 'Đã xác nhận'; statusTextColor = Colors.green; break;
      case 'completed': statusText = 'Hoàn thành'; statusTextColor = Colors.blue; break;
      case 'cancelled': statusText = 'Đã hủy'; statusTextColor = Colors.red; break;
      default: statusText = 'Chờ xử lý'; statusTextColor = Colors.orange;
    }

    final bool isCompleted = appointment.status == 'completed';
    final bool isCancelled = appointment.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                ),
                child: (avatarUrl == null || avatarUrl.isEmpty) ? const Icon(Icons.person, color: Colors.blue) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(statusText, style: TextStyle(fontSize: 12, color: statusTextColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                child: Text(appointment.timeSlot, style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => ChatScreen(receiverId: appointment.userId, receiverName: patientName));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Nhắn tin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (isCompleted || isCancelled) ? null : () {
                    Get.to(() => ExaminationScreen(appointment: appointment));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.grey : Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isCompleted ? 'Đã khám' : (isCancelled ? 'Đã hủy' : 'Khám ngay'), style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}