import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallPage extends StatelessWidget {
  final String callID; 
  final String userName; 

  const CallPage({
    super.key,
    required this.callID,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ZegoUIKitPrebuiltCall(
      appID: 1628811426, // [QUAN TRỌNG] Thay bằng AppID của bạn
      appSign: "135029373c52b8cd16de257052fdf466d78d14f23db202c0875b209e44d4b499", // [QUAN TRỌNG] Thay bằng AppSign của bạn
      userID: user?.uid ?? 'guest',
      userName: userName,
      callID: callID,
      
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

      events: ZegoUIKitPrebuiltCallEvents(
        // 1. Khi mình bấm nút đỏ (Kết thúc)
        onCallEnd: (event, defaultAction) {
          defaultAction.call();
          Navigator.of(context).pop();
        },
        
        // 2. Khi người kia thoát
        user: ZegoUIKitPrebuiltCallUserEvents(
          // --- SỬA Ở ĐÂY: Xóa chữ "ZegoUIKitUser" đi, chỉ để lại (user) ---
          onLeave: (user) { 
            debugPrint('Người dùng khác đã rời phòng');
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}