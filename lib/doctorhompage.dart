import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/features/account/account.dart'; 
// Nếu bạn đã có trang Chat, hãy import vào đây. Ví dụ:
// import 'package:tech_care/features/chat/conversation_list_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0; 

  // Lấy ngày hiện tại dạng chuỗi "yyyy-MM-dd"
  String get _currentDateString {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  // --- CẬP NHẬT: Thêm case 2 là Tin nhắn ---
  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(); // Trang chủ Dashboard
      case 1:
        return const Center(child: Text('Quản lý Lịch làm việc', style: TextStyle(fontSize: 20)));
      case 2:
        // Thay thế widget này bằng màn hình danh sách cuộc trò chuyện của bạn
        return const Center(child: Text('Tin nhắn với Bệnh nhân', style: TextStyle(fontSize: 20)));
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

      // --- CẬP NHẬT: Thêm item Tin nhắn vào BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Quan trọng: fixed để hiển thị đủ 5 icon
        selectedItemColor: Colors.blue[800], 
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch',
          ),
          // --- MỤC TIN NHẮN MỚI ---
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Tin nhắn',
          ),
          // -------------------------
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Bệnh nhân',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  // --- WIDGET: DASHBOARD (Giữ nguyên không đổi) ---
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
                  _currentDateString,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildAppointmentList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Các Widget con (Header, Stats, List) giữ nguyên ---

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
          _buildStatCard('Tin nhắn', '5', Icons.message, Colors.green), // Đổi Bệnh nhân thành Tin nhắn cho dashboard sinh động
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
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user?.uid)
        .where('date', isEqualTo: _currentDateString);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
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
            return _buildAppointmentItem(appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    final patientName = appointment.patientProfile['fullName'] ??
        appointment.patientProfile['name'] ??
        'Bệnh nhân ẩn danh';

    String statusText;
    Color statusColor;
    
    switch (appointment.status) {
      case 'confirmed': statusText = 'Đã xác nhận'; statusColor = Colors.green; break;
      case 'completed': statusText = 'Hoàn thành'; statusColor = Colors.blue; break;
      case 'cancelled': statusText = 'Đã hủy'; statusColor = Colors.red; break;
      default: statusText = 'Chờ xử lý'; statusColor = Colors.orange;
    }

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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  image: appointment.patientProfile['avatarUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(
                              appointment.patientProfile['avatarUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: appointment.patientProfile['avatarUrl'] == null
                    ? const Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
              const SizedBox(width: 12),
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
                            color: statusColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                     // TODO: Chuyển sang màn hình chat với bệnh nhân này
                     // Get.to(() => ChatDetailScreen(userId: appointment.userId));
                  },
                  child: const Text('Nhắn tin'), // Đổi nút Hồ sơ thành Nhắn tin cho tiện
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700]),
                  child: const Text('Khám ngay',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}