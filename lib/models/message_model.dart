class Message {
  final String senderId;
  final String text;
  final int timestamp; // Dùng int (milliseconds) cho RTDB dễ sắp xếp

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Chuyển từ JSON (RTDB trả về Map) sang Object
  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  // Chuyển từ Object sang Map để đẩy lên RTDB
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}