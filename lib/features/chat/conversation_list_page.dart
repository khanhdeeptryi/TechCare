import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/chat/chat_screen.dart'; // Import màn hình chat chi tiết

class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      // Lắng nghe toàn bộ node messages để tìm phòng chat
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

          // 1. Lấy danh sách tất cả Key phòng chat (VD: userA_userB)
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final List<String> myChatRoomIds = [];

          data.forEach((key, value) {
            // Nếu key chứa ID của mình -> Đây là cuộc trò chuyện của mình
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
              
              // 3. Tách ID để tìm người kia (Target User ID)
              // Logic: chatRoomId = "ID1_ID2". Nếu mình là ID1 thì người kia là ID2 và ngược lại.
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
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Chưa có tin nhắn nào", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Widget lấy thông tin Bác sĩ từ Firestore dựa trên ID
  Widget _buildConversationItem(String targetUserId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('doctors').doc(targetUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Đang tải hoặc lỗi thì ẩn tạm
        }

        // Nếu không tìm thấy trong collection 'doctors', thử tìm trong 'users' (phòng trường hợp admin chat)
        // Ở đây giả định đối phương là Bác sĩ
        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        
        // Fallback tên nếu chưa tải được
        String name = userData?['name'] ?? userData?['fullName'] ?? 'Bác sĩ';
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
              "Nhấn để xem tin nhắn", 
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Chuyển sang màn hình Chat chi tiết
              Get.to(() => ChatScreen(
                receiverId: targetUserId,
                receiverName: name,
              ));
            },
          ),
        );
      },
    );
  }
}