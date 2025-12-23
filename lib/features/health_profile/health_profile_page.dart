import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/features/account/update_personal_info_page.dart';
import 'package:tech_care/models/appointment_model.dart'; // Import model Appointment

class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ sức khỏe"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => const UpdatePersonalInfoPage());
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Thông tin chung"),
            Tab(text: "Lịch sử khám"),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: THÔNG TIN CÁ NHÂN (Code cũ)
          _buildGeneralInfoTab(user),
          
          // TAB 2: LỊCH SỬ KHÁM BỆNH (Code mới)
          _buildHistoryTab(user),
        ],
      ),
    );
  }

  // --- TAB 1: THÔNG TIN CHUNG ---
  Widget _buildGeneralInfoTab(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Center(child: Text("Chưa có dữ liệu hồ sơ"));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final String fullName = data['fullName'] ?? 'Chưa cập nhật';
        final String height = data['height'] ?? '--';
        final String weight = data['weight'] ?? '--';
        final String gender = data['gender'] ?? '--';
        final String cccd = data['cccd'] ?? 'Chưa cập nhật';
        final String bhyt = data['bhyt'] ?? 'Chưa cập nhật';
        List<dynamic> images = data['medicalRecordImages'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thẻ Avatar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Giới tính: $gender", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              const Text("CHỈ SỐ CƠ THỂ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildInfoCard(Icons.height, "Chiều cao", "$height cm", Colors.orange),
                  const SizedBox(width: 12),
                  _buildInfoCard(Icons.monitor_weight, "Cân nặng", "$weight kg", Colors.green),
                ],
              ),

              const SizedBox(height: 20),
              const Text("THÔNG TIN PHÁP LÝ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildLegalRow("Số CCCD/CMND", cccd, Icons.credit_card),
                    const Divider(),
                    _buildLegalRow("Mã số BHYT", bhyt, Icons.health_and_safety),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text("KHO HỒ SƠ BỆNH ÁN (OFFLINE)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),

              if (images.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_off, size: 50, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      const Text("Chưa có hồ sơ lưu trữ", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.dialog(
                          Stack(
                            children: [
                              PhotoViewer(imageUrl: images[index]),
                              Positioned(
                                top: 40, right: 20,
                                child: GestureDetector(
                                  onTap: () => Get.back(),
                                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                                ),
                              ),
                            ],
                          ),
                          useSafeArea: false,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
               const SizedBox(height: 40), 
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: LỊCH SỬ KHÁM (Code mới) ---
  Widget _buildHistoryTab(User user) {
    final Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
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
                Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Chưa có lịch sử khám bệnh online.", style: TextStyle(color: Colors.grey[600])),
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
            return _buildRecordCard(context, appointment);
          },
        );
      },
    );
  }

  // --- WIDGET CON CHO TAB 2 ---
  Widget _buildRecordCard(BuildContext context, Appointment appointment) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(appointment.appointmentTime.toDate());
    final diagnosis = appointment.examinationResult?.diagnosis ?? "Chưa có chẩn đoán";
    final doctorName = appointment.doctorInfo['name'] ?? "Bác sĩ";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(() => MedicalRecordDetailScreen(appointment: appointment));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(dateStr, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(diagnosis.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("BS. $doctorName", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CON CHO TAB 1 ---
  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- MÀN HÌNH CHI TIẾT (Đơn thuốc) ---
// --- MÀN HÌNH CHI TIẾT (Đơn thuốc & Hình ảnh) ---
class MedicalRecordDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const MedicalRecordDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final result = appointment.examinationResult;
    if (result == null) return const Scaffold(body: Center(child: Text("Lỗi dữ liệu")));

    // Lấy danh sách ảnh đính kèm (nếu có)
    final List<String> attachments = result.attachments ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết khám bệnh"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 1
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Chẩn đoán", result.diagnosis, Icons.local_hospital, Colors.red),
            _buildSection("Triệu chứng", result.symptoms, Icons.sick, Colors.orange),
            _buildSection("Lời dặn", result.doctorNotes, Icons.note, Colors.blue),
            
            const SizedBox(height: 20),
            
            // --- [MỚI] HIỂN THỊ HÌNH ẢNH ĐÍNH KÈM ---
            if (attachments.isNotEmpty) ...[
              const Text("Hình ảnh / Tài liệu đính kèm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 ảnh 1 hàng
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Xem ảnh full màn hình (dùng lại PhotoViewer)
                      Get.dialog(
                        Stack(
                          children: [
                            PhotoViewer(imageUrl: attachments[index]),
                            Positioned(
                              top: 40, right: 20,
                              child: GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(Icons.close, color: Colors.white, size: 30),
                              ),
                            ),
                          ],
                        ),
                        useSafeArea: false,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: NetworkImage(attachments[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            // ----------------------------------------

            const Text("Đơn thuốc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            if (result.prescription.isEmpty)
              const Text("Không có đơn thuốc", style: TextStyle(color: Colors.grey))
            else
              ...result.prescription.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item.dosage} | ${item.frequency}\n${item.duration}"),
                ),
              )).toList(),
              
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text(content.isEmpty ? "Không có thông tin" : content, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// Widget xem ảnh phóng to
class PhotoViewer extends StatelessWidget {
  final String imageUrl;
  const PhotoViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}