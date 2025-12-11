import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Tạo hoặc lấy chat room giữa 2 users
  Future<String> createOrGetChatRoom({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final currentUid = currentUserId;

    // Tạo ID duy nhất bằng cách sort 2 UIDs
    final participants = [currentUid, otherUserId]..sort();
    final chatRoomId = '${participants[0]}_${participants[1]}';

    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    final doc = await chatRoomRef.get();

    if (!doc.exists) {
      // Tạo chat room mới
      final chatRoom = ChatRoom(
        id: chatRoomId,
        participants: [currentUid, otherUserId],
        participantNames: {
          currentUid: _auth.currentUser?.displayName ?? 'User',
          otherUserId: otherUserName,
        },
        lastMessage: '',
        lastMessageTime: Timestamp.now(),
        createdAt: Timestamp.now(),
      );
      await chatRoomRef.set(chatRoom.toMap());
    }

    return chatRoomId;
  }

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    final message = Message(
      id: _firestore.collection('chatRooms').doc().id,
      senderId: currentUserId,
      text: text,
      type: type,
      imageUrl: imageUrl,
      timestamp: Timestamp.now(),
      isRead: false,
    );

    // Thêm message vào subcollection
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    // Update lastMessage trong chatRoom
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTime': message.timestamp,
    });
  }

  /// Lấy danh sách chat rooms của user hiện tại
  Stream<List<ChatRoom>> getChatRooms() {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Lấy messages của một chat room
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Đánh dấu tin nhắn đã đọc
  Future<void> markAsRead(String chatRoomId, String messageId) async {
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}
