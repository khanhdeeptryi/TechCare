import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/chat/chat_screen.dart'; // Import màn hình chat

class DoctorHistoryForChatPage extends StatelessWidget {
  const DoctorHistoryForChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Query: Lấy các lịch hẹn của user này mà trạng thái là 'completed' (đã khám xong)
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user?.uid)
        .where('status', isEqualTo: 'confirmed') 
        .orderBy('appointmentTime', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn bác sĩ để chat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // 3. Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Bạn chưa khám hoàn tất với bác sĩ nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 4. XỬ LÝ LỌC TRÙNG BÁC SĨ (Logic quan trọng)
          final List<Map<String, dynamic>> uniqueDoctors = [];
          final Set<String> processedDoctorIds = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? doctorId = data['doctorId'];
            
            // Nếu có ID bác sĩ và chưa từng thêm vào danh sách
            if (doctorId != null && !processedDoctorIds.contains(doctorId)) {
              processedDoctorIds.add(doctorId); // Đánh dấu đã xử lý
              
              // Lấy info từ snapshot appointment (vì bạn đã lưu doctorInfo trong đó)
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

          // 5. Hiển thị danh sách bác sĩ duy nhất
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uniqueDoctors.length,
            itemBuilder: (context, index) {
              final doc = uniqueDoctors[index];
              return _buildDoctorCard(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctorData) {
    final String name = "${doctorData['title']}. ${doctorData['name']}";
    final String avatarUrl = doctorData['imageUrl'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue[50],
          backgroundImage: (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          child: (avatarUrl.isEmpty) ? const Icon(Icons.person, color: Colors.blue) : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(doctorData['specialty'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.history, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text("Đã từng khám", style: TextStyle(color: Colors.green, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            )
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chat_bubble, color: Colors.blue),
          onPressed: () {
            // CHUYỂN SANG MÀN HÌNH CHAT
            Get.to(() => ChatScreen(
              receiverId: doctorData['id'],
              receiverName: name,
            ));
          },
        ),
        onTap: () {
          Get.to(() => ChatScreen(
            receiverId: doctorData['id'],
            receiverName: name,
          ));
        },
      ),
    );
  }
}