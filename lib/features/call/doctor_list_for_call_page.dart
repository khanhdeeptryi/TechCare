import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/call/call_page.dart'; // Import trang gọi Zego

class DoctorListForCallPage extends StatelessWidget {
  const DoctorListForCallPage({super.key});

  // Hàm tạo ID phòng gọi trùng khớp với ID phòng chat
  String _getCallID(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserName = user?.email ?? "Người dùng"; // Lấy tên hiển thị

    // Query: Lấy các lịch hẹn đã hoàn thành
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user?.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('appointmentTime', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn bác sĩ để gọi"),
        backgroundColor: Colors.blue, // Màu xanh đặc trưng cho Video Call
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Bạn chưa có bác sĩ nào trong lịch sử khám."));
          }

          // Lọc trùng bác sĩ
          final List<Map<String, dynamic>> uniqueDoctors = [];
          final Set<String> processedDoctorIds = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? doctorId = data['doctorId'];
            
            if (doctorId != null && !processedDoctorIds.contains(doctorId)) {
              processedDoctorIds.add(doctorId);
              final doctorInfo = data['doctorInfo'] as Map<String, dynamic>? ?? {};
              uniqueDoctors.add({
                'id': doctorId,
                'name': doctorInfo['name'] ?? 'Bác sĩ',
                'title': doctorInfo['title'] ?? 'BS',
                'specialty': doctorInfo['specialty'] ?? 'Đa khoa',
                'imageUrl': doctorInfo['imageUrl'] ?? '',
              });
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uniqueDoctors.length,
            itemBuilder: (context, index) {
              final doc = uniqueDoctors[index];
              final String doctorName = "${doc['title']}. ${doc['name']}";
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: doc['imageUrl'].isNotEmpty ? NetworkImage(doc['imageUrl']) : null,
                    child: doc['imageUrl'].isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['specialty']),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam, color: Colors.blue),
                  ),
                  onTap: () {
                    // --- BẮT ĐẦU CUỘC GỌI ---
                    final callID = _getCallID(user!.uid, doc['id']);
                    Get.to(() => CallPage(
                      callID: callID,
                      userName: currentUserName,
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