import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // [QUAN TRỌNG] Để chuyển trang

import 'package:tech_care/features/chat/chat_service.dart';
import '../../models/message_model.dart';
import 'package:tech_care/features/call/call_page.dart'; // [QUAN TRỌNG] Import màn hình gọi

class ChatScreen extends StatefulWidget {
  final String receiverId; // ID người nhận (Bệnh nhân hoặc Bác sĩ)
  final String receiverName; // Tên người nhận để hiện lên AppBar

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        _auth.currentUser!.uid,
        widget.receiverId,
        _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- [MỚI] Hàm tạo ID phòng gọi (để 2 bên trùng khớp nhau) ---
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); 
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser!.uid;
    // Lấy tên mình để hiện bên máy người kia khi gọi
    final currentUserName = _auth.currentUser!.email ?? "Người dùng"; 

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        
        // --- [QUAN TRỌNG] PHẦN NÚT GỌI BỊ THIẾU TRƯỚC ĐÓ ---
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, size: 28),
            onPressed: () {
              // 1. Tạo Call ID
              final callID = _getChatRoomId(currentUserId, widget.receiverId);

              // 2. Chuyển sang màn hình gọi
              Get.to(() => CallPage(
                callID: callID,
                userName: currentUserName, 
              ));
            },
          ),
          const SizedBox(width: 10), // Khoảng cách lề phải
        ],
        // -----------------------------------------------------
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 1. DANH SÁCH TIN NHẮN
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _chatService.getMessages(currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("Hãy bắt đầu cuộc trò chuyện"));
                }

                Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Message> messages = [];
                
                map.forEach((key, value) {
                  messages.add(Message.fromMap(value));
                });

                messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessageItem(msg, isMe);
                  },
                );
              },
            ),
          ),

          // 2. KHUNG NHẬP TIN NHẮN
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(msg.timestamp));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}