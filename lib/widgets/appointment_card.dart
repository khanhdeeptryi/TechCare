import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/models/appointment_model.dart'; 

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap; // Thêm callback khi bấm vào thẻ
  final VoidCallback? onCancel; // Callback hủy
  final VoidCallback? onViewResult; // Callback xem kết quả

  const AppointmentCard({
    Key? key, 
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.onViewResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Xử lý thời gian hiển thị
    final DateTime date = appointment.appointmentTime.toDate();
    final String dateStr = DateFormat('dd/MM/yyyy').format(date);
    // Ưu tiên hiển thị TimeSlot (VD: 08:00 - 08:30) nếu có, không thì lấy giờ từ Timestamp
    final String timeStr = appointment.timeSlot.isNotEmpty 
        ? appointment.timeSlot 
        : DateFormat('HH:mm').format(date);
    final String displayTime = "$timeStr, $dateStr";

    // 2. Xử lý thông tin Đơn vị cung cấp (Bác sĩ/Clinic/Hospital)
    String providerLabel = "Dịch vụ:";
    String providerName = "Không rõ";
    IconData providerIcon = Icons.local_hospital_outlined;

    if (appointment.bookingType == 'doctor' && appointment.doctorData != null) {
      providerLabel = "Bác sĩ:";
      providerName = appointment.doctorData!['name'] ?? '';
      providerIcon = Icons.person_outline;
    } 
    else if (appointment.bookingType == 'clinic' && appointment.clinicData != null) {
      providerLabel = "Phòng khám:";
      providerName = appointment.clinicData!['name'] ?? '';
      providerIcon = Icons.store_outlined;
    } 
    else if (appointment.bookingType == 'hospital' && appointment.hospitalData != null) {
      providerLabel = "Bệnh viện:";
      providerName = appointment.hospitalData!['name'] ?? '';
      providerIcon = Icons.apartment_outlined;
    }

    // 3. Lấy tên bệnh nhân
    final String patientName = appointment.patientProfile['fullName'] ?? 
                               appointment.patientProfile['name'] ?? 'Không rõ';

    // 4. Lấy trạng thái
    final statusInfo = _getStatusInfo(appointment.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusInfo['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusInfo['icon'], color: statusInfo['color'], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          statusInfo['text'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: statusInfo['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Có thể thêm menu option (3 chấm) ở đây nếu cần
                ],
              ),
              const Divider(height: 24),

              // Thông tin chi tiết
              _buildInfoRow(
                icon: Icons.access_time,
                title: 'Thời gian:',
                content: displayTime,
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                icon: Icons.person_outline,
                title: 'Bệnh nhân:',
                content: patientName,
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                icon: providerIcon,
                title: providerLabel,
                content: providerName,
              ),

              // Nút hành động
              // Trường hợp: Sắp tới (Pending/Confirmed) -> Hiện nút Hủy
              if (appointment.status == 'pending' || appointment.status == 'confirmed')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      if (onCancel != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Hủy lịch'),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Trường hợp: Đã hoàn thành -> Hiện nút Xem kết quả
              if (appointment.status == 'completed' && onViewResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Xem kết quả khám'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Xây dựng hàng thông tin
  Widget _buildInfoRow({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        SizedBox(
          width: 80, // Độ rộng cố định cho nhãn để thẳng hàng
          child: Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper: Lấy thông tin màu sắc/icon theo trạng thái
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'confirmed':
        return {
          'text': 'Đã xác nhận',
          'icon': Icons.check_circle_outline,
          'color': Colors.green[700],
          'bgColor': Colors.green[50],
        };
      case 'pending':
        return {
          'text': 'Chờ xác nhận',
          'icon': Icons.hourglass_empty,
          'color': Colors.orange[800],
          'bgColor': Colors.orange[50],
        };
      case 'completed':
        return {
          'text': 'Hoàn thành',
          'icon': Icons.task_alt,
          'color': Colors.blue[700],
          'bgColor': Colors.blue[50],
        };
      case 'cancelled':
        return {
          'text': 'Đã hủy',
          'icon': Icons.cancel_outlined,
          'color': Colors.red[700],
          'bgColor': Colors.red[50],
        };
      default:
        return {
          'text': 'Không rõ',
          'icon': Icons.help_outline,
          'color': Colors.grey[700],
          'bgColor': Colors.grey[200],
        };
    }
  }
}