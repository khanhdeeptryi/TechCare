import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class VideoCallScreen extends StatelessWidget {
  final String doctorId;

  VideoCallScreen({super.key, required this.doctorId});

  final JitsiMeet _jitsiMeet = JitsiMeet();

  Future<void> _startCall() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userId = user.uid;
    final displayName = user.displayName ?? user.email ?? 'Patient';

    // roomName phải TRÙNG bên phía bác sĩ
    final roomName = 'room_${userId}_$doctorId';

    final options = JitsiMeetConferenceOptions(
      room: roomName,
      serverURL: "https://meet.jit.si", // server public miễn phí
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "subject": "Tư vấn sức khỏe với bác sĩ",
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: user.email,
      ),
    );

    await _jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gọi video với bác sĩ')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.video_call),
          label: const Text('Bắt đầu cuộc gọi'),
          onPressed: _startCall,
        ),
      ),
    );
  }
}
