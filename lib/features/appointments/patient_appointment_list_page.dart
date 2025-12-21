import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart'; 

class PatientAppointmentListPage extends StatelessWidget {
  const PatientAppointmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lịch khám của tôi"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Sắp tới"),
              Tab(text: "Lịch sử"),
            ],
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: const TabBarView(
          children: [
            // Tab 1: Lịch sắp tới
            AppointmentListTab(statuses: ['pending', 'confirmed']),
            // Tab 2: Lịch sử
            AppointmentListTab(statuses: ['completed', 'cancelled']),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET CON: DANH SÁCH LỊCH ---
class AppointmentListTab extends StatelessWidget {
  final List<String> statuses;

  const AppointmentListTab({
    super.key,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Query: Lọc theo userId và status
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user?.uid)
        .where('status', whereIn: statuses)
        // --- SỬA Ở ĐÂY ---
        // descending: true -> Ngày lớn (mới nhất/xa nhất) xếp lên đầu
        .orderBy('appointmentTime', descending: true); 

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  "Bạn chưa có lịch hẹn nào",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final appointment = Appointment.fromFirestore(data, docs[index].id);
            return _buildPatientAppointmentCard(appointment);
          },
        );
      },
    );
  }

  Widget _buildPatientAppointmentCard(Appointment appointment) {
    // 1. Xác định tên Bác sĩ / Phòng khám / Bệnh viện
    String titleName = "Dịch vụ y tế";
    String subInfo = "";
    String imageUrl = "";

    // Xử lý an toàn null cho doctorInfo
    final info = appointment.doctorInfo;
    
    if (appointment.bookingType == 'doctor') {
      titleName = "BS. ${info['name'] ?? ''}";
      subInfo = info['specialty'] ?? '';
      imageUrl = info['imageUrl'] ?? '';
    } else if (appointment.bookingType == 'clinic') {
      titleName = info['name'] ?? 'Phòng khám';
      subInfo = info['address'] ?? '';
      imageUrl = info['imageUrl'] ?? '';
    } else {
       // Fallback cho các loại khác hoặc lỗi data
       titleName = info['name'] ?? 'Y tế';
       subInfo = info['address'] ?? '';
    }

    // 2. Format ngày giờ
    final dateStr = DateFormat('dd/MM/yyyy').format(appointment.appointmentTime.toDate());
    final timeStr = appointment.timeSlot;

    // 3. Màu sắc trạng thái
    String statusText;
    Color statusColor;
    Color statusBgColor;

    switch (appointment.status) {
      case 'confirmed':
        statusText = 'Đã xác nhận';
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
        break;
      case 'pending':
        statusText = 'Chờ xác nhận';
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'completed':
        statusText = 'Đã hoàn thành';
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.shade50;
        break;
      case 'cancelled':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade50;
        break;
      default:
        statusText = 'Không rõ';
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: imageUrl.isEmpty ? const Icon(Icons.local_hospital, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              
              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subInfo,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}