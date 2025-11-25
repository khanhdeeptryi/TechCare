import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/hospital.dart';
import '../../../models/patient_profile.dart';
import 'success_screen.dart';

class HospitalConfirmationScreen extends StatefulWidget {
  final Hospital hospital;
  final PatientProfile patientProfile;
  final DateTime selectedDate;
  final String selectedTimeSlot; // "HH:mm-HH:mm"
  final String serviceType;      // "normal" | "vip"

  const HospitalConfirmationScreen({
    Key? key,
    required this.hospital,
    required this.patientProfile,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<HospitalConfirmationScreen> createState() =>
      _HospitalConfirmationScreenState();
}

class _HospitalConfirmationScreenState
    extends State<HospitalConfirmationScreen> {
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Bạn chưa đăng nhập");

      // Tách giờ bắt đầu
      final startTimeString =
          widget.selectedTimeSlot.split('-')[0].trim();
      final timeParts = startTimeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final DateTime appointmentDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        hour,
        minute,
      );

      final String bookingCode =
          'YMA${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final String dateStr =
          DateFormat('yyyy-MM-dd').format(widget.selectedDate);

      final Map<String, dynamic> appointmentData = {
        'userId': user.uid,
        'bookingType': 'hospital',
        'status': 'confirmed',
        'bookingCode': bookingCode,
        'createdAt': FieldValue.serverTimestamp(),
        'appointmentTime': Timestamp.fromDate(appointmentDateTime),
        'date': dateStr,
        'timeSlot': widget.selectedTimeSlot,

        'hospitalId': widget.hospital.id,
        'hospitalInfo': {
          'name': widget.hospital.name,
          'address': widget.hospital.address,
          'imageUrl': widget.hospital.imageUrl,
        },

        'serviceType': widget.serviceType, // normal | vip

        'patientProfile': widget.patientProfile.toMap(),
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      Get.offAll(() => const SuccessScreen());
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Đặt lịch thất bại: $e",
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
        .format(widget.selectedDate);
    final serviceLabel =
        widget.serviceType == 'vip' ? 'Khám VIP' : 'Khám thường';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Xác nhận thông tin"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepper(),
            _buildWarningBox(),

            // Thông tin đăng ký
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("THÔNG TIN ĐĂNG KÝ"),
                  _buildHospitalInfo(),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Giờ khám",
                            widget.selectedTimeSlot,
                            isBold: true,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Ngày khám",
                            dateStr,
                            isBold: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildInfoItem(
                      "Hình thức khám",
                      serviceLabel,
                      isBold: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildInfoItem(
                      "Địa chỉ",
                      widget.hospital.address,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Thông tin bệnh nhân
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("THÔNG TIN BỆNH NHÂN"),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPatientRow(
                          "Họ và tên",
                          widget.patientProfile.fullName,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPatientRow(
                                "Giới tính",
                                widget.patientProfile.gender,
                              ),
                            ),
                            Expanded(
                              child: _buildPatientRow(
                                "Ngày sinh",
                                widget.patientProfile.dob,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPatientRow(
                          "Điện thoại liên hệ",
                          widget.patientProfile.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildPatientRow("Mã bảo hiểm y tế", "--"),
                        const SizedBox(height: 12),
                        _buildPatientRow("Địa chỉ", "--"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Thanh toán
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "CHI TIẾT THANH TOÁN",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                      Icon(Icons.help_outline,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentRow("Phí khám", "0đ"),
                  const SizedBox(height: 8),
                  _buildPaymentRow("Phí tiện ích", "Miễn phí"),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Tổng thanh toán",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "0đ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Xác nhận đặt lịch",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  // === Widget con ===

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem("1", "Chọn lịch",
              isActive: false, isCompleted: true),
          _buildConnector(isActive: true),
          _buildStepItem("2", "Xác nhận",
              isActive: true, isCompleted: false),
          _buildConnector(isActive: false),
          _buildStepItem("3", "Hoàn tất",
              isActive: false, isCompleted: false),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    String number,
    String label, {
    required bool isActive,
    required bool isCompleted,
  }) {
    Color color =
        isCompleted ? Colors.green : (isActive ? Colors.blue : Colors.grey);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : (isActive ? Colors.blue : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  number,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Container(
      width: 30,
      height: 1,
      color: isActive ? Colors.blue : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Text(
        "Hãy kiểm tra các thông tin trước khi xác nhận. Nếu bạn cần hỗ trợ, vui lòng liên hệ tổng đài 1900-2805.",
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildHospitalInfo() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: widget.hospital.imageUrl.isNotEmpty
                ? NetworkImage(widget.hospital.imageUrl)
                : null,
            backgroundColor: Colors.grey[200],
            child: widget.hospital.imageUrl.isEmpty
                ? const Icon(Icons.local_hospital, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hospital.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.hospital.address,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight:
                isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}
