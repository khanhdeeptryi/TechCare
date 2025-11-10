import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tech_care/wrapper.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      // Hiển thị snackbar thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Đợi một chút để user thấy snackbar trước khi chuyển trang
      await Future.delayed(Duration(milliseconds: 500));
      Get.offAll(Wrapper());
    } on FirebaseAuthException catch (e) {
      String msg = '';

      if (e.code == 'weak-password') msg = 'Password should be at least 6 characters.';
      else if (e.code == 'email-already-in-use') msg = 'An account already exists for that email.';
      else if (e.code == 'invalid-email') msg = 'Invalid email';
      else msg = 'An error occurred: ${e.message}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Sign up")),
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
              ElevatedButton(onPressed: (()=>signup()), child: Text("Sign up"))
            ],
          ),
        )
    );
  }
}
