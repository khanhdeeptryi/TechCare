import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Thư viện mã QR
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Import trang chủ để quay về
// Đảm bảo đường dẫn import đúng với project của bạn
import '../../../homepage.dart'; 

class SuccessScreen extends StatelessWidget {
  // Bỏ tham số bookingCode
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy thời gian hiện tại
    final nowStr = DateFormat('HH:mm:ss dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Get.offAll(() => const Homepage());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // TODO: Tính năng chia sẻ ảnh vé
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Icon thành công
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Đã đặt lịch",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              nowStr,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Vé đặt lịch (Card chứa QR)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Phần trên: Số thứ tự và QR
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("STT", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            // Giả lập số thứ tự
                            const Text("1", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // Mã QR (Mã hóa chuỗi mặc định vì không có bookingCode)
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: QrImageView(
                            data: "DAT_LICH_THANH_CONG", // Dữ liệu mã hóa tạm thời
                            version: QrVersions.auto,
                            size: 100.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Đường kẻ đứt đoạn
                  Row(
                    children: List.generate(30, (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0 ? Colors.transparent : Colors.grey[300],
                        height: 1,
                      ),
                    )),
                  ),

                  // Phần dưới: Thông tin chi tiết
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Đã bỏ dòng hiển thị Mã lịch khám
                        _buildTicketRow("Trạng thái", "Đã xác nhận"),
                        const SizedBox(height: 12),
                        const Text(
                          "Vui lòng đưa mã này cho nhân viên y tế khi đến khám.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  
                  // Nút xem chi tiết
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Xem chi tiết",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danh sách các hành động hỗ trợ
            _buildActionList(),

            const SizedBox(height: 24),
            
            // Nút Về trang chủ
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.offAll(() => const Homepage());
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Về trang chủ", style: TextStyle(color: Colors.black)),
              ),
            ),
             const SizedBox(height: 12),
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Mở màn hình chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Chat với bác sĩ", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionList() {
    return Column(
      children: [
        _buildActionItem(Icons.chat_bubble_outline, "Chat với CSKH"),
        _buildActionItem(Icons.description_outlined, "Hướng dẫn đặt khám"),
        _buildActionItem(Icons.payment, "Hướng dẫn thanh toán"),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}