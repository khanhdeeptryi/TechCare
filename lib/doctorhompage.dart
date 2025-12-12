import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // [QUAN TRỌNG] Để dùng Get.to

// --- CÁC MODEL VÀ MÀN HÌNH LIÊN QUAN ---
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/features/account/account.dart';
import 'package:tech_care/features/examination/examination_screen.dart'; // [QUAN TRỌNG] Màn hình khám bệnh
import 'package:tech_care/features/chat/chat_screen.dart';
import 'package:tech_care/features/chat/doctor_conversation_list_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  // Lấy ngày hiện tại để hiển thị (VD: 05/12/2025)
  String get _currentDateDisplay {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy').format(now);
  }

  // --- ĐIỀU HƯỚNG TAB ---
  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(); // Dashboard chính
      case 1:
        return const Center(child: Text('Quản lý Lịch làm việc', style: TextStyle(fontSize: 20)));
      case 2:
        return DoctorConversationListPage();
      case 3:
        return const Center(child: Text('Danh sách Bệnh nhân', style: TextStyle(fontSize: 20)));
      case 4:
        return const Account();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _getPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bệnh nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  // --- DASHBOARD UI ---
  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatsDashboard(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch hẹn hôm nay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _currentDateDisplay,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildAppointmentList(), // Danh sách lịch hẹn
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.medical_services, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào,', style: TextStyle(color: Colors.white70)),
                  Text(
                    user?.email ?? 'Bác sĩ',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm hồ sơ bệnh nhân...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Lịch hẹn', '12', Icons.calendar_today, Colors.orange),
          _buildStatCard('Tin nhắn', '5', Icons.message, Colors.green),
          _buildStatCard('Đánh giá', '4.8', Icons.star, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- DANH SÁCH LỊCH HẸN (QUERY THEO KHOẢNG THỜI GIAN) ---
  Widget _buildAppointmentList() {
    // 1. Lấy mốc thời gian bắt đầu và kết thúc ngày hôm nay
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    // 2. Query Firestore
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user?.uid)
        .where('appointmentTime', isGreaterThanOrEqualTo: startTimestamp)
        .where('appointmentTime', isLessThanOrEqualTo: endTimestamp)
        .orderBy('appointmentTime', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Lỗi tải dữ liệu: ${snapshot.error}\n(Vui lòng kiểm tra Console để tạo Index nếu cần)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Icon(Icons.calendar_today_outlined,
                    size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text('Hôm nay trống lịch',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final appointment = Appointment.fromFirestore(data, docId);
            
            // Gọi Widget Item đã được cập nhật logic
            return _buildAppointmentItem(appointment);
          },
        );
      },
    );
  }

  // --- ITEM LỊCH HẸN (Đã cập nhật logic Khám ngay) ---
  Widget _buildAppointmentItem(Appointment appointment) {
    // 1. Lấy thông tin an toàn
    final patientName = appointment.patientProfile['fullName'] ??
        appointment.patientProfile['name'] ??
        'Bệnh nhân ẩn danh';
    
    final avatarUrl = appointment.patientProfile['avatarUrl'];

    // 2. Xác định trạng thái
    String statusText;
    Color statusTextColor;
    
    switch (appointment.status) {
      case 'confirmed': statusText = 'Đã xác nhận'; statusTextColor = Colors.green; break;
      case 'completed': statusText = 'Hoàn thành'; statusTextColor = Colors.blue; break;
      case 'cancelled': statusText = 'Đã hủy'; statusTextColor = Colors.red; break;
      default: statusText = 'Chờ xử lý'; statusTextColor = Colors.orange;
    }

    // 3. Logic vô hiệu hóa nút
    final bool isCompleted = appointment.status == 'completed';
    final bool isCancelled = appointment.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Tên và Trạng thái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(statusText,
                        style: TextStyle(
                            fontSize: 12,
                            color: statusTextColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Giờ khám (Badge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20)),
                child: Text(appointment.timeSlot,
                    style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Hàng nút hành động
          Row(
            children: [
              // Nút Nhắn tin
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Mở màn hình Chat với Bệnh nhân
                    Get.to(() => ChatScreen(
                      receiverId: appointment.userId, // ID của bệnh nhân
                      receiverName: patientName,      // Tên bệnh nhân (đã lấy ở trên)
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Nhắn tin'), 
                ),
              ),
              const SizedBox(width: 12),

              // Nút Khám ngay
              Expanded(
                child: ElevatedButton(
                  onPressed: (isCompleted || isCancelled) 
                      ? null // Vô hiệu hóa nếu xong hoặc hủy
                      : () {
                          // Chuyển sang màn hình Khám bệnh
                          Get.to(() => ExaminationScreen(appointment: appointment));
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.grey : Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                  ),
                  child: Text(
                      isCompleted ? 'Đã khám' : (isCancelled ? 'Đã hủy' : 'Khám ngay'),
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}