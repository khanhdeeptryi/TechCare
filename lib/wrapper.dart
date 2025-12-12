import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_care/features/authenticate/login.dart';

// Import 2 trang chủ
import 'package:tech_care/homepage.dart'; 
import 'package:tech_care/doctorhompage.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) { // Đổi tên biến snapshot để tránh nhầm lẫn với snapshot bên trong
        
        // 1. Chờ kết nối Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Nếu có lỗi Auth
        if (authSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Đã xảy ra lỗi xác thực')),
          );
        }

        // 3. Nếu ĐÃ ĐĂNG NHẬP
        if (authSnapshot.hasData) {
          final User user = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) { // Đổi tên snapshot thành userSnapshot
              
              // Đang tải dữ liệu User từ Firestore
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Nếu có lỗi khi tải Firestore
              if (userSnapshot.hasError) {
                 return const Scaffold(
                  body: Center(child: Text('Lỗi tải dữ liệu người dùng')),
                );
              }

              // KIỂM TRA DỮ LIỆU TỒN TẠI
              if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final String role = userData['role'] ?? 'user';

                if (role == 'doctor') {
                  return const DoctorHomePage();
                } else {
                  return const Homepage();
                }
              }

              // --- TRƯỜNG HỢP RỦI RO (Edge Case) ---
              // User đã đăng nhập Auth thành công nhưng KHÔNG TÌM THẤY dữ liệu trong Firestore.
              // (Ví dụ: Document bị xóa nhầm, hoặc lỗi mạng lúc đăng ký).
              // Hành động: Đăng xuất ngay để user không bị kẹt, và trả về Login.
              FirebaseAuth.instance.signOut(); 
              return const Login();
            },
          );
        }

        // 4. Nếu CHƯA ĐĂNG NHẬP
        return const Login();
      },
    );
  }
}