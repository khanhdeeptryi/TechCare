import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart';
// Nhớ import trang chi tiết nếu có

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
            AppointmentListTab(statuses: ['pending', 'confirmed']),
            AppointmentListTab(statuses: ['completed', 'cancelled']),
          ],
        ),
      ),
    );
  }
}

class AppointmentListTab extends StatelessWidget {
  final List<String> statuses;
  const AppointmentListTab({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user?.uid)
        .where('status', whereIn: statuses)
        .orderBy('appointmentTime', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("Không có lịch hẹn nào", style: TextStyle(color: Colors.grey[600])),
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
    // 1. Biến hiển thị mặc định
    String titleName = "Dịch vụ y tế";
    String subInfo = "";
    String imageUrl = "";
    IconData placeholderIcon = Icons.local_hospital;

    // 2. Logic "Dò tìm dữ liệu" (Fix lỗi Lịch sử)
    // Xác định xem nên lấy data từ map nào (doctor/clinic/hospital)
    
    Map<String, dynamic>? data;
    String type = (appointment.bookingType).toLowerCase().trim();

    // Bước A: Thử lấy theo đúng loại bookingType
    if (type == 'doctor') {
      data = appointment.doctorData;
    } else if (type == 'clinic') data = appointment.clinicData;
    else if (type == 'hospital') data = appointment.hospitalData;

    // Bước B: Nếu không có (do data cũ bị null hoặc sai type), tự động dò các trường còn lại
    if (data == null) {
      if (appointment.doctorData != null) {
        data = appointment.doctorData;
        type = 'doctor';
      } else if (appointment.clinicData != null) {
        data = appointment.clinicData;
        type = 'clinic';
      } else if (appointment.hospitalData != null) {
        data = appointment.hospitalData;
        type = 'hospital';
      }
    }

    // 3. Hiển thị dữ liệu sau khi đã dò tìm
    if (data != null) {
      // --- TRƯỜNG HỢP BÁC SĨ ---
      if (type == 'doctor') {
        titleName = "BS. ${data['name'] ?? 'Không tên'}";
        // Xử lý chuyên khoa (có thể là List hoặc String)
        var specs = data['specialties'] ?? data['specialty']; 
        if (specs is List) {
          subInfo = specs.join(", ");
        } else {
          subInfo = specs?.toString() ?? data['title'] ?? 'Bác sĩ chuyên khoa';
        }
        placeholderIcon = Icons.person;
      } 
      // --- TRƯỜNG HỢP PHÒNG KHÁM ---
      else if (type == 'clinic') {
        titleName = data['name'] ?? 'Phòng khám';
        subInfo = data['address'] ?? 'Địa chỉ phòng khám';
        placeholderIcon = Icons.store;
      } 
      // --- TRƯỜNG HỢP BỆNH VIỆN ---
      else if (type == 'hospital') {
        titleName = data['name'] ?? 'Bệnh viện';
        subInfo = data['address'] ?? 'Địa chỉ bệnh viện';
        placeholderIcon = Icons.apartment;
      }
      
      imageUrl = data['imageUrl'] ?? '';
    }

    // --- PHẦN UI (Card) ---
    final DateTime dateTime = appointment.appointmentTime.toDate();
    final String dateStr = DateFormat('dd/MM/yyyy').format(dateTime);
    final String timeStr = appointment.timeSlot.isNotEmpty 
        ? appointment.timeSlot 
        : DateFormat('HH:mm').format(dateTime);

    String statusText;
    Color statusColor;
    Color statusBgColor;

    switch (appointment.status) {
      case 'confirmed':
        statusText = 'Đã xác nhận'; statusColor = Colors.green[700]!; statusBgColor = Colors.green[50]!; break;
      case 'pending':
        statusText = 'Chờ xác nhận'; statusColor = Colors.orange[800]!; statusBgColor = Colors.orange[50]!; break;
      case 'completed':
        statusText = 'Hoàn thành'; statusColor = Colors.blue[700]!; statusBgColor = Colors.blue[50]!; break;
      case 'cancelled':
        statusText = 'Đã hủy'; statusColor = Colors.red[700]!; statusBgColor = Colors.red[50]!; break;
      default:
        statusText = 'Không rõ'; statusColor = Colors.grey[700]!; statusBgColor = Colors.grey[200]!;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
           // Điều hướng đến chi tiết (nếu có)
           // Get.to(() => MedicalRecordDetailScreen(appointment: appointment));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                    ),
                    child: imageUrl.isEmpty ? Icon(placeholderIcon, color: Colors.grey, size: 30) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titleName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(subInfo, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.blue[600]), const SizedBox(width: 6), Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                      const SizedBox(height: 4),
                      Row(children: [Icon(Icons.access_time, size: 14, color: Colors.blue[600]), const SizedBox(width: 6), Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(statusText, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}