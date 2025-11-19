import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/homepage.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint(
          'Wrapper authStateChanges: '
          'state=${snapshot.connectionState}, '
          'hasData=${snapshot.hasData}, '
          'user=${snapshot.data}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const Homepage();
        } else {
          return const Login();
        }
      },
    );
  }
}

