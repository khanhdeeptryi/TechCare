// File: lib/features/chat/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';
import '../../models/chat_room_model.dart';
import 'chat_screen.dart';

/// ChatListScreen - Danh sách các cuộc hội thoại
class ChatListScreen extends StatelessWidget {
  final bool isDoctor;

  const ChatListScreen({Key? key, required this.isDoctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có tin nhắn nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              // Lấy ID người kia (không phải current user)
              final otherUserId = chatRoom.participants.firstWhere(
                (id) => id != chatService.currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(isDoctor ? 'users' : 'doctors')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  String displayName = 'User';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final data =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    displayName =
                        data?['name'] ??
                        data?['displayName'] ??
                        data?['email'] ??
                        'User';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      child: Icon(
                        isDoctor ? Icons.person : Icons.medical_services,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chatRoom.lastMessage.isEmpty
                          ? 'Bắt đầu cuộc trò chuyện'
                          : chatRoom.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatRoom.id,
                            otherUserId: otherUserId,
                            otherUserName: displayName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
