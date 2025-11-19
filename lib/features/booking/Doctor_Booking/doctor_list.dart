import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/doctor.dart';
import '../../../widgets/doctor_card.dart';
import 'booking_screen.dart';
import 'package:get/get.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhạt cho toàn màn hình
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(), // Hàng chứa các chip lọc
          const SizedBox(height: 8), // Khoảng cách nhỏ
          
          // StreamBuilder để tải dữ liệu
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Truy vấn đến collection 'doctors'
              stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                // Hiển thị vòng xoay loading khi đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Hiển thị lỗi nếu có
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }

                // Kiểm tra nếu không có dữ liệu
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không tìm thấy bác sĩ nào.'));
                }

                // Lấy danh sách tài liệu từ snapshot
                final doctorDocs = snapshot.data!.docs;

                // Sử dụng ListView.builder để hiển thị danh sách
                return ListView.builder(
                  itemCount: doctorDocs.length,
                  itemBuilder: (context, index) {
                    // Lấy dữ liệu thô (Map) từ document
                    final docData = doctorDocs[index].data() as Map<String, dynamic>;
                    final docId = doctorDocs[index].id;
                    
                    // Chuyển đổi Map thành đối tượng Doctor
                    final doctor = Doctor.fromFirestore(docData, docId);
                    
                    // Trả về DoctorCard widget
                    return DoctorCard(
                      doctor: doctor,
                      onBookPressed: () { // <-- DÒNG NÀY BẮT BUỘC PHẢI CÓ
                        // Xử lý khi nhấn nút Đặt lịch
                        Get.to(() => BookingScreen(doctor: doctor));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng AppBar tùy chỉnh
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white, // Màu nền AppBar
      elevation: 1.0, // Đường viền mỏng
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // Xử lý sự kiện quay lại
        },
      ),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Tên bác sĩ, triệu chứng, chuyên khoa',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none, // Bỏ viền
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        ),
      ),
      actions: [
        // Đây có thể là nơi bạn đặt các icon hệ thống, 
        // nhưng thông thường chúng là của OS, không phải của app.
        // Bỏ qua nếu không cần thiết.
      ],
    );
  }

  // Xây dựng hàng chip lọc
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white, // Nền trắng cho khu vực chip
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chip "Tất cả"
          ActionChip(
            avatar: const Icon(Icons.menu, size: 18),
            label: const Text('Tất cả'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),
          
          // Chip "Nơi khám"
          ActionChip(
            avatar: const Icon(Icons.add_location_outlined, size: 18),
            label: const Text('Nơi khám: Bác sĩ'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),

          // Chip "Bộ lọc"
          ActionChip(
            avatar: const Icon(Icons.filter_list, size: 18),
            label: const Text('Bộ lọc'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),
        ],
      ),
    );
  }
}