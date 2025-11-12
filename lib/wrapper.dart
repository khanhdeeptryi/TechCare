import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/homepage.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // lắng nghe user login/logout
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // đang chờ Firebase load trạng thái user
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // có user => đã đăng nhập
          return const Homepage();
        } else {
          // chưa đăng nhập => vào trang login
          return const Login();
        }
      },
    );
  }
}
