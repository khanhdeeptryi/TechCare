import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, callInvite }

class Message {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final String? imageUrl;
  final Timestamp timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.type,
    this.imageUrl,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromFirestore(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      type: _parseMessageType(data['type']),
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;
    if (type is String) {
      switch (type) {
        case 'image':
          return MessageType.image;
        case 'callInvite':
          return MessageType.callInvite;
        default:
          return MessageType.text;
      }
    }
    return MessageType.text;
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
