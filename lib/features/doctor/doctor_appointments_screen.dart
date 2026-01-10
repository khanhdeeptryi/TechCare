import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';

/// DoctorAppointmentsScreen - Màn hình quản lý lịch khám của bác sĩ
class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _currentDoctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch khám'),
        backgroundColor: const Color(0xFF00BFA6),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Lịch sử'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList('pending', showActions: true),
          _buildAppointmentList('confirmed', showActions: false),
          _buildAppointmentList(['completed', 'cancelled'], showActions: false),
        ],
      ),
    );
  }

  /// Build danh sách lịch hẹn theo status
  Widget _buildAppointmentList(
    dynamic statusFilter, {
    required bool showActions,
  }) {
    Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: _currentDoctorId);

    // Xử lý filter theo status
    if (statusFilter is String) {
      query = query.where('status', isEqualTo: statusFilter);
    } else if (statusFilter is List<String>) {
      query = query.where('status', whereIn: statusFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('appointmentTime', descending: false).snapshots(),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Không có lịch hẹn',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final doc = appointments[index];
            final appointment = Appointment.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );

            return AppointmentCard(
              appointment: appointment,
              showActions: showActions,
              onAccept: () =>
                  _updateAppointmentStatus(appointment.id, 'confirmed'),
              onReject: () =>
                  _updateAppointmentStatus(appointment.id, 'cancelled'),
            );
          },
        );
      },
    );
  }

  /// Cập nhật trạng thái lịch hẹn
  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus, 'updatedAt': Timestamp.now()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'confirmed'
                  ? 'Đã nhận lịch khám'
                  : 'Đã từ chối lịch khám',
            ),
            backgroundColor: newStatus == 'confirmed'
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// AppointmentCard - Widget thẻ hiển thị thông tin lịch hẹn
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.showActions,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin từ patientProfile
    final patientName =
        appointment.patientProfile['name'] as String? ?? 'Bệnh nhân';
    final patientPhone = appointment.patientProfile['phone'] as String? ?? '';

    // Format thời gian
    final appointmentDate = appointment.appointmentTime.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(appointmentDate);
    final formattedTime = appointment.timeSlot;

    // Xác định màu status badge
    Color statusColor;
    String statusText;
    switch (appointment.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Chờ duyệt';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = appointment.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Patient Info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00BFA6).withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF00BFA6),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (patientPhone.isNotEmpty)
                        Text(
                          patientPhone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Appointment details
            _buildDetailRow(Icons.calendar_today, 'Ngày khám', formattedDate),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Giờ khám', formattedTime),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.medical_services,
              'Loại khám',
              _getBookingTypeText(appointment.bookingType),
            ),

            // Action buttons for pending appointments
            if (showActions && appointment.status == 'pending') ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Nhận lịch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getBookingTypeText(String type) {
    switch (type) {
      case 'doctor':
        return 'Khám bác sĩ';
      case 'clinic':
        return 'Phòng khám';
      case 'hospital':
        return 'Bệnh viện';
      default:
        return type;
    }
  }
}
