import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/models/appointment_model.dart'; // Import model của bạn

class ExaminationScreen extends StatefulWidget {
  final Appointment appointment;

  const ExaminationScreen({super.key, required this.appointment});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  // Controllers cho các trường nhập liệu
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  // Danh sách đơn thuốc tạm thời
  final List<PrescriptionItem> _prescriptions = [];

  bool _isSubmitting = false;

  // --- HÀM THÊM THUỐC ---
  void _addMedicine() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm thuốc"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên thuốc (VD: Panadol)"),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: "Liều lượng (VD: 500mg)"),
              ),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(labelText: "Tần suất (VD: Sáng 1, Chiều 1)"),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: "Thời gian (VD: 5 ngày)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _prescriptions.add(PrescriptionItem(
                    name: nameController.text,
                    dosage: dosageController.text,
                    frequency: frequencyController.text,
                    duration: durationController.text,
                  ));
                });
                Get.back();
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  // --- HÀM LƯU KẾT QUẢ KHÁM ---
  Future<void> _completeExamination() async {
    if (_diagnosisController.text.isEmpty) {
      Get.snackbar("Thiếu thông tin", "Vui lòng nhập chẩn đoán bệnh.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Tạo object ExaminationResult từ dữ liệu nhập
      final result = ExaminationResult(
        symptoms: _symptomsController.text,
        diagnosis: _diagnosisController.text,
        doctorNotes: _notesController.text,
        prescription: _prescriptions,
        attachments: [], // Có thể phát triển tính năng upload ảnh sau
      );

      // 2. Cập nhật vào Firestore
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointment.id)
          .update({
        'status': 'completed', // Đổi trạng thái thành hoàn thành
        'examinationResult': result.toMap(), // Lưu kết quả khám
      });

      Get.back(); // Đóng màn hình
      Get.snackbar("Thành công", "Đã hoàn tất ca khám!", 
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu kết quả: $e", 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin bệnh nhân
    final profile = widget.appointment.patientProfile;
    final name = profile['fullName'] ?? profile['name'] ?? 'N/A';
    final age = profile['dob'] ?? 'N/A'; // Có thể tính tuổi từ DOB
    final gender = profile['gender'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Khám bệnh"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD THÔNG TIN BỆNH NHÂN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Giới tính: $gender  •  Ngày sinh: $age"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. KHÁM LÂM SÀNG
            const Text("Lâm sàng & Chẩn đoán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            TextField(
              controller: _symptomsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Triệu chứng bệnh & Lý do khám",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: "Chẩn đoán / Kết luận",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),

            const SizedBox(height: 24),

            // 3. KÊ ĐƠN THUỐC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Đơn thuốc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                TextButton.icon(
                  onPressed: _addMedicine,
                  icon: const Icon(Icons.add),
                  label: const Text("Thêm thuốc"),
                ),
              ],
            ),
            // Hiển thị danh sách thuốc đã thêm
            if (_prescriptions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Chưa có thuốc nào được kê.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _prescriptions.length,
                itemBuilder: (context, index) {
                  final item = _prescriptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.medication, color: Colors.orange),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.dosage} - ${item.frequency} (${item.duration})"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _prescriptions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // 4. LỜI DẶN
            const Text("Dặn dò", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Lời dặn của bác sĩ (Ăn uống, tái khám...)",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            // 5. BUTTON HOÀN TẤT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _completeExamination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("HOÀN TẤT KHÁM BỆNH", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}