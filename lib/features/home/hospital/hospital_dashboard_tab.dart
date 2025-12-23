import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'hospital_appointment_list_widget.dart'; 

class HospitalDashboardTab extends StatelessWidget {
  const HospitalDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo[800],
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.apartment, color: Colors.indigo)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Xin chào,', style: TextStyle(color: Colors.white70)),
                    Text(user?.email ?? 'Bệnh viện', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Lịch hẹn hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          
          HospitalAppointmentListWidget(
            selectedDate: DateTime.now(),
            isDashboard: true, // Để tránh lỗi layout
          ),
        ],
      ),
    );
  }
}