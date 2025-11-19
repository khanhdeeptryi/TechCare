// File: lib/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm 'intl' vào pubspec.yaml
import '../models/appointment_model.dart'; // Import model lịch hẹn

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Định dạng thời gian
    final String formattedTime = DateFormat('HH:mm, dd/MM/yyyy')
        .format(appointment.appointmentTime.toDate());

    // Lấy thông tin từ Map
    final String doctorName = appointment.doctorInfo['name'] ?? 'Không rõ bác sĩ';
    final String patientName = appointment.patientProfile['fullName'] ?? 'Không rõ bệnh nhân';

    // Lấy thông tin trạng thái
    final statusInfo = _getStatusInfo(appointment.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng trạng thái
            Row(
              children: [
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 20),
                const SizedBox(width: 8),
                Text(
                  statusInfo['text'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusInfo['color'],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Thông tin chi tiết
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Thời gian:',
              content: formattedTime,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person_outline,
              title: 'Bệnh nhân:',
              content: patientName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              title: 'Bác sĩ:',
              content: doctorName,
            ),

            // Nút hành động (nếu lịch chưa hoàn thành)
            if (appointment.status == 'confirmed')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () { /* TODO: Hủy lịch */ },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Hủy lịch'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () { /* TODO: Xem chi tiết / Check-in */ },
                        child: const Text('Xem chi tiết'),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Nút xem kết quả (nếu lịch đã hoàn thành)
            if (appointment.status == 'completed')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { /* TODO: Điều hướng đến trang kết quả khám */ },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Xem kết quả khám'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ lấy thông tin trạng thái
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'completed':
        return {
          'text': 'Đã hoàn thành',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case 'cancelled':
        return {
          'text': 'Đã hủy',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
      case 'confirmed':
      default:
        return {
          'text': 'Đã xác nhận',
          'icon': Icons.hourglass_top,
          'color': Colors.blue,
        };
    }
  }

  // Hàm hỗ trợ xây dựng hàng thông tin
  Widget _buildInfoRow({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$title ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}