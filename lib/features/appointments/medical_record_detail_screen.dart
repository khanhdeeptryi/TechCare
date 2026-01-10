import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/models/appointment_model.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const MedicalRecordDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final result = appointment.examinationResult;

    // --- 1. LOGIC LẤY TÊN ĐƠN VỊ KHÁM (Bác sĩ/Phòng khám/Bệnh viện) ---
    String providerName = "Đơn vị y tế";
    Map<String, dynamic>? data;
    String type = appointment.bookingType.toLowerCase();

    // Ưu tiên lấy data theo type chuẩn
    if (type == 'doctor') {
      data = appointment.doctorData;
    } else if (type == 'clinic') data = appointment.clinicData;
    else if (type == 'hospital') data = appointment.hospitalData;

    // Fallback: Nếu không tìm thấy, thử dò trong các trường khác (cho data cũ)
    if (data == null) {
      if (appointment.doctorData != null) { data = appointment.doctorData; type = 'doctor'; }
      else if (appointment.clinicData != null) { data = appointment.clinicData; type = 'clinic'; }
      else if (appointment.hospitalData != null) { data = appointment.hospitalData; type = 'hospital'; }
    }

    if (data != null) {
      if (type == 'doctor') {
        providerName = "BS. ${data['name'] ?? ''}";
      } else {
        providerName = data['name'] ?? 'Cơ sở y tế';
      }
    }
    // -------------------------------------------------------------------

    // Nếu chưa có kết quả khám
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết phiếu khám")),
        body: const Center(
          child: Text("Hồ sơ này chưa có kết quả khám bệnh.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final List<String> attachments = result.attachments;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kết quả khám bệnh", style: TextStyle(fontSize: 18)),
            Text(providerName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: THÔNG TIN CHẨN ĐOÁN ---
            _buildSection("Chẩn đoán", result.diagnosis, Icons.local_hospital, Colors.red),
            _buildSection("Triệu chứng", result.symptoms, Icons.sick, Colors.orange),
            _buildSection("Lời dặn", result.doctorNotes, Icons.note, Colors.blue),

            const SizedBox(height: 20),

            // --- PHẦN 2: HÌNH ẢNH / TÀI LIỆU ---
            if (attachments.isNotEmpty) ...[
              const Text("Hình ảnh / Tài liệu đính kèm", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  final url = attachments[index];
                  // Kiểm tra url rỗng để tránh lỗi
                  if (url.isEmpty) return const SizedBox();

                  return GestureDetector(
                    onTap: () {
                      // Mở ảnh phóng to
                      Get.dialog(PhotoViewer(imageUrl: url));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          // Xử lý lỗi nếu ảnh không load được
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // --- PHẦN 3: ĐƠN THUỐC ---
            const Text("Đơn thuốc", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),

            if (result.prescription.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text("Không có thuốc được kê", style: TextStyle(color: Colors.grey)),
              )
            else
              ...result.prescription.map((item) => Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8)
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[50],
                    child: const Icon(Icons.medication, color: Colors.green, size: 20),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.dosage} | ${item.frequency}\n${item.duration}"),
                  isThreeLine: true,
                ),
              )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget con để vẽ từng mục thông tin
  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? "Không có thông tin" : content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget xem ảnh phóng to (Zoom được)
class PhotoViewer extends StatelessWidget {
  final String imageUrl;
  const PhotoViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => 
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text("Không tải được ảnh", style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 14))
                      ],
                    ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40, 
          right: 20, 
          child: GestureDetector(
            onTap: () => Get.back(), 
            child: const Icon(Icons.close, color: Colors.white, size: 30)
          )
        ),
      ],
    );
  }
}