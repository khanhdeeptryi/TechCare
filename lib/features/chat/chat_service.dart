import 'package:firebase_database/firebase_database.dart';
import '../../models/message_model.dart';

class ChatService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // 1. Tạo Chat ID duy nhất giữa 2 người (để dù ai mở chat cũng vào đúng phòng)
  String getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }

  // 2. Gửi tin nhắn
  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final String chatRoomId = getChatRoomId(senderId, receiverId);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final Message newMessage = Message(
      senderId: senderId,
      text: text,
      timestamp: timestamp,
    );

    // Đẩy tin nhắn vào node: messages / chatRoomId / push_id_ngẫu_nhiên
    await _dbRef
        .child('messages')
        .child(chatRoomId)
        .push()
        .set(newMessage.toMap());
  }

  // 3. Lấy Stream tin nhắn (Realtime)
  Stream<DatabaseEvent> getMessages(String userId, String otherUserId) {
    final String chatRoomId = getChatRoomId(userId, otherUserId);
    
    // Lắng nghe node messages/chatRoomId, sắp xếp theo timestamp
    return _dbRef
        .child('messages')
        .child(chatRoomId)
        .orderByChild('timestamp')
        .onValue;
  }
}