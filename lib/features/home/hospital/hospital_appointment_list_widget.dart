import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/chat/chat_screen.dart';
import 'package:tech_care/features/examination/examination_screen.dart';
import 'package:tech_care/models/appointment_model.dart';

class HospitalAppointmentListWidget extends StatelessWidget {
  final DateTime selectedDate;
  final bool isDashboard; // Biến kiểm soát layout (Dashboard hay Schedule)

  const HospitalAppointmentListWidget({
    super.key, 
    required this.selectedDate,
    this.isDashboard = false, 
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final start = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0));
    final end = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));

    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('hospitalId', isEqualTo: user?.uid) // Lọc theo Hospital ID
        .where('appointmentTime', isGreaterThanOrEqualTo: start)
        .where('appointmentTime', isLessThanOrEqualTo: end)
        .orderBy('appointmentTime');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return isDashboard 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Không có lịch hẹn")))
            : const Center(child: Text("Không có lịch hẹn"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          // --- XỬ LÝ LAYOUT ---
          shrinkWrap: isDashboard, 
          physics: isDashboard ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          // -------------------
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final appointment = Appointment.fromFirestore(data, snapshot.data!.docs[index].id);
            final patientName = appointment.patientProfile['fullName'] ?? 'Ẩn danh';
            final bool isDone = appointment.status == 'completed' || appointment.status == 'cancelled';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    appointment.timeSlot, 
                    style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold)
                  ),
                ),
                title: Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Trạng thái: ${appointment.status}"),
                trailing: ElevatedButton(
                  onPressed: isDone ? null : () => Get.to(() => ExaminationScreen(appointment: appointment)),
                  style: ElevatedButton.styleFrom(backgroundColor: isDone ? Colors.grey : Colors.indigo),
                  child: const Text("Khám", style: TextStyle(color: Colors.white)),
                ),
                onTap: () => Get.to(() => ChatScreen(receiverId: appointment.userId, receiverName: patientName)),
              ),
            );
          },
        );
      },
    );
  }
}