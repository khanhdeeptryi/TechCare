import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_screen.dart'; // Import màn hình chat

class DoctorConversationListPage extends StatelessWidget {
  const DoctorConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn bệnh nhân"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút back vì đây là trang trong Tab
      ),
      backgroundColor: Colors.grey[100],
      // Lắng nghe node messages
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('messages').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _buildEmptyState();
          }

          // 1. Lấy danh sách các phòng chat có chứa ID của Bác sĩ
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final List<String> myChatRoomIds = [];

          data.forEach((key, value) {
            if (key.toString().contains(currentUserId)) {
              myChatRoomIds.add(key.toString());
            }
          });

          if (myChatRoomIds.isEmpty) {
            return _buildEmptyState();
          }

          // 2. Hiển thị danh sách
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myChatRoomIds.length,
            itemBuilder: (context, index) {
              final chatRoomId = myChatRoomIds[index];
              
              // Tách ID để lấy ID của Bệnh nhân
              final parts = chatRoomId.split('_');
              final targetUserId = (parts[0] == currentUserId) ? parts[1] : parts[0];

              return _buildConversationItem(targetUserId);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_chat_unread_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Chưa có tin nhắn nào", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Widget lấy thông tin BỆNH NHÂN từ Firestore (Collection 'users')
  Widget _buildConversationItem(String patientId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Đang tải thì ẩn
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        
        // Lấy tên bệnh nhân (Fallback nếu không có tên)
        String name = userData?['fullName'] ?? userData?['name'] ?? userData?['email'] ?? 'Bệnh nhân';
        String? avatarUrl = userData?['avatarUrl'];

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue[50],
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                  ? NetworkImage(avatarUrl) 
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty) 
                  ? const Icon(Icons.person, color: Colors.blue) 
                  : null,
            ),
            title: Text(
              name, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text(
              "Nhấn để chat", 
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            onTap: () {
              // Vào màn hình Chat
              Get.to(() => ChatScreen(
                receiverId: patientId,
                receiverName: name,
              ));
            },
          ),
        );
      },
    );
  }
}