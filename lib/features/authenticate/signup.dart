import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_care/wrapper.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Các role: 'user', 'doctor', 'clinic', 'hospital'
  String selectedRole = 'user';

  signup() async {
    // 1. Kiểm tra mật khẩu khớp nhau
    if (password.text.trim() != confirmPassword.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // 2. Tạo tài khoản Authentication
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final String uid = cred.user!.uid;
      final Timestamp now = Timestamp.now();

      // 3. Luôn lưu vào collection 'users' (Bảng tổng)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.text.trim(),
        'role': selectedRole, // Lưu vai trò đã chọn
        'createdAt': now,
      });

      // 4. LOGIC PHÂN LOẠI DATA THEO ROLE
      
      // --- TRƯỜNG HỢP: BÁC SĨ ---
      if (selectedRole == 'doctor') {
        await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
          'id': uid,
          'uid': uid,
          'email': email.text.trim(),
          'role': 'doctor',
          'createdAt': now,
          // Dữ liệu mặc định
          'name': '',
          'title': '',
          'experience': 0,
          'address': '',
          'imageUrl': '',
          'specialties': [],
          'bio': '',
          'rating': 5.0,
          'patientCount': 0,
        });
      } 
      // --- TRƯỜNG HỢP: PHÒNG KHÁM ---
      else if (selectedRole == 'clinic') {
        await FirebaseFirestore.instance.collection('clinics').doc(uid).set({
          'id': uid,
          'uid': uid,
          'email': email.text.trim(),
          'role': 'clinic',
          'createdAt': now,
          // Dữ liệu mặc định cho Phòng khám
          'name': '',           // Tên phòng khám
          'address': '',        // Địa chỉ
          'hotline': '',        // Số điện thoại liên hệ
          'imageUrl': '',       // Logo/Ảnh phòng khám
          'description': '',    // Giới thiệu
          'services': [],       // Các dịch vụ cung cấp
          'rating': 5.0,
          'openHours': '',      // Giờ mở cửa
        });
      }
      // --- TRƯỜNG HỢP: BỆNH VIỆN ---
      else if (selectedRole == 'hospital') {
        await FirebaseFirestore.instance.collection('hospitals').doc(uid).set({
          'id': uid,
          'uid': uid,
          'email': email.text.trim(),
          'role': 'hospital',
          'createdAt': now,
          // Dữ liệu mặc định cho Bệnh viện
          'name': '',           // Tên bệnh viện
          'address': '',        // Địa chỉ
          'hotline': '',        // Hotline cấp cứu/CSKH
          'imageUrl': '',       // Ảnh bệnh viện
          'description': '',    // Giới thiệu chung
          'departments': [],    // Danh sách chuyên khoa
          'rating': 5.0,
          'website': '',        // Website bệnh viện
        });
      }

      // 5. Thông báo thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(Wrapper()); 
      
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'weak-password') {
        msg = 'Password should be at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else {
        msg = 'An error occurred: ${e.message}';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("TechCare"),
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1,
                    size: 64, color: Colors.blue[400]),
                const SizedBox(height: 16),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.blue[400]),
                    hintText: 'Enter your email',
                    filled: true,
                    fillColor: Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.blue[400]),
                    hintText: 'Enter password',
                    filled: true,
                    fillColor: Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue[300],
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.lock_reset, color: Colors.blue[400]),
                    hintText: 'Confirm password',
                    filled: true,
                    fillColor: Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue[300],
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Select Role:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // --- GIAO DIỆN CHỌN ROLE (Cập nhật để chứa 4 loại) ---
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.0, // Khoảng cách ngang
                  runSpacing: 5.0, // Khoảng cách dọc
                  children: [
                    _buildRoleChip('user', 'User'),
                    _buildRoleChip('doctor', 'Doctor'),
                    _buildRoleChip('clinic', 'Clinic'),
                    _buildRoleChip('hospital', 'Hospital'),
                  ],
                ),
                
                const SizedBox(height: 28),

                // Nút đăng ký
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Sign up",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nút quay lại
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con để tạo nút chọn Role cho gọn code
  Widget _buildRoleChip(String value, String label) {
    final bool isSelected = selectedRole == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          selectedRole = value;
        });
      },
      selectedColor: Colors.blue[100],
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[900] : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}