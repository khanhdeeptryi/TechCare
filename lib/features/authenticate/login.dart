import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/authenticate/forgot.dart';
import 'package:tech_care/features/authenticate/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text
      );

      // Hiển thị snackbar thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Log chi tiết lỗi để debug
      print('FirebaseAuthException code: ${e.code}');
      print('FirebaseAuthException message: ${e.message}');

      String msg = '';

      if (e.code == 'user-not-found') {
        msg = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        msg = 'This account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Too many attempts. Please try again later.';
      } else if (e.code == 'invalid-credential') {
        msg = 'Invalid email or password.';
      } else {
        msg = 'An error occurred: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('General exception: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: 'Enter password'),
            ),
            ElevatedButton(onPressed: (()=>signIn()), child: Text("Login")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (()=>Get.to(Signup())), child: Text("Register now")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (()=>Get.to(Forgot())), child: Text("Forgot password")),
          ],
        ),
      )
    );
  }
}
