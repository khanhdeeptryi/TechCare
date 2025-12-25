import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Import các model và màn hình cần thiết
import 'package:tech_care/homepage.dart'; 
import 'package:tech_care/models/appointment_model.dart';
import 'package:tech_care/utils/prescription_parser.dart'; 

class PatientUploadRecordScreen extends StatefulWidget {
  const PatientUploadRecordScreen({super.key});

  @override
  State<PatientUploadRecordScreen> createState() => _PatientUploadRecordScreenState();
}

class _PatientUploadRecordScreenState extends State<PatientUploadRecordScreen> {
  bool _isScanning = false;
  bool _isSaving = false;
  File? _imageFile;
  
  List<PrescriptionItem> _medicines = [];
  
  final TextEditingController _diagnosisController = TextEditingController(text: "Toa thuốc cũ (Tự tải lên)");

  // --- HELPER: Upload ảnh lên Firebase Storage ---
  Future<String> uploadFileToStorage(File? file) async {
    if (file == null) return "";

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Chưa đăng nhập");

      final fileName = "prescriptions/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Upload ảnh thất bại: $e");
    }
  }

  // --- 1. HÀM XỬ LÝ SCAN ẢNH ---
  Future<void> _scanImage(ImageSource source) async {
    setState(() => _isScanning = true);
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }

      setState(() => _imageFile = File(image.path));

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Gọi Parser mới
      final result = PrescriptionParser.parse(recognizedText.text);
      
      setState(() {
        _medicines = result.medicines;
        if (result.diagnosis.isNotEmpty) {
          _diagnosisController.text = result.diagnosis;
        }
      });
      
      if (result.medicines.isEmpty) {
        Get.snackbar("Lưu ý", "Không tìm thấy thuốc. Vui lòng kiểm tra lại ảnh hoặc tự thêm thuốc.");
      } else {
        Get.snackbar("Thành công", "Đã tìm thấy ${result.medicines.length} thuốc & Chẩn đoán.");
      }

      textRecognizer.close();
    } catch (e) {
      Get.snackbar("Lỗi OCR", "Không thể đọc văn bản: $e");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  // --- 2. HÀM LƯU VÀO FIREBASE ---
  Future<void> _saveToFirestore() async {
    if (_medicines.isEmpty && _imageFile == null) {
      Get.snackbar("Thiếu thông tin", "Vui lòng scan ảnh hoặc nhập thuốc");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Chưa đăng nhập");

      // A. Upload ảnh lên Storage
      String imageUrl = await uploadFileToStorage(_imageFile); 
    
      // B. Tạo dữ liệu Appointment (Loại lịch sử)
      final appointmentData = {
        'userId': user.uid,
        'bookingType': 'historical', 
        'status': 'completed', 
        'appointmentTime': Timestamp.now(),
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toString().split(' ')[0],
        'timeSlot': 'Tự tải lên',
        
        'doctorData': null,
        'clinicData': null,
        'hospitalData': {
          'name': 'Bệnh án tự tải lên',
          'address': 'Cập nhật bởi bệnh nhân',
          'imageUrl': '',
        },

        'examinationResult': {
          'diagnosis': _diagnosisController.text,
          'symptoms': 'Được quét từ toa thuốc cũ',
          'doctorNotes': 'Lưu ý kiểm tra lại thông tin thuốc do máy quét',
          'prescription': _medicines.map((e) => e.toMap()).toList(),
          'attachments': [imageUrl], 
        },
        
        'patientProfile': {
          'fullName': user.email ?? 'Tôi',
          'phone': '',
        }
      };

      await FirebaseFirestore.instance.collection('appointments').add(appointmentData);

      Get.snackbar("Thành công", "Đã lưu bệnh án vào lịch sử");
      Get.offAll(() => const Homepage()); 

    } catch (e) {
      Get.snackbar("Lỗi", "Lưu thất bại: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- [MỚI] 3. HỘP THOẠI THÊM / SỬA THUỐC ---
  // Nếu index == null -> Thêm mới
  // Nếu index != null -> Sửa
  void _showMedicineDialog({int? index}) {
    final isEditing = index != null;
    final item = isEditing ? _medicines[index] : null;

    final nameCtrl = TextEditingController(text: item?.name ?? "");
    final qtyCtrl = TextEditingController(text: item?.dosage ?? "");
    final usageCtrl = TextEditingController(text: item?.frequency ?? "");

    Get.defaultDialog(
      title: isEditing ? "Chỉnh sửa thuốc" : "Thêm thuốc mới",
      content: Column(
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên thuốc")),
          const SizedBox(height: 8),
          TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Số lượng (VD: 10 Viên)")),
          const SizedBox(height: 8),
          TextField(controller: usageCtrl, decoration: const InputDecoration(labelText: "HDSD (VD: Sáng 1 viên)")),
        ],
      ),
      textConfirm: "Lưu",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty) {
          Get.snackbar("Lỗi", "Tên thuốc không được để trống");
          return;
        }

        final newItem = PrescriptionItem(
          name: nameCtrl.text.trim(), 
          dosage: qtyCtrl.text.trim(), 
          frequency: usageCtrl.text.trim(), 
          duration: ""
        );

        setState(() {
          if (isEditing) {
            _medicines[index] = newItem;
          } else {
            _medicines.add(newItem);
          }
        });
        Get.back();
      }
    );
  }

  // --- [MỚI] 4. HÀM XÓA THUỐC ---
  void _deleteMedicine(int index) {
    Get.defaultDialog(
      title: "Xóa thuốc",
      middleText: "Bạn có chắc muốn xóa thuốc này?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        setState(() {
          _medicines.removeAt(index);
        });
        Get.back();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tải lên toa thuốc cũ")),
      body: Column(
        children: [
          // Khu vực ảnh
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[200],
            child: _imageFile != null 
              ? Image.file(_imageFile!, fit: BoxFit.contain)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.document_scanner, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _scanImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Chụp ảnh"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _scanImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Thư viện"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue
                          ),
                        ),
                      ],
                    )
                  ],
                ),
          ),
          
          if (_isScanning) const LinearProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(
                    labelText: "Tên bệnh / Chẩn đoán",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                ),
                const SizedBox(height: 10),
                
                // --- [MỚI] NÚT THÊM THUỐC THỦ CÔNG ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showMedicineDialog(index: null), // index null -> Thêm mới
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm thuốc thủ công"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      side: BorderSide(color: Colors.blue[800]!),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _medicines.isEmpty 
              ? Center(
                  child: Text(
                    _imageFile == null 
                      ? "Vui lòng chụp hoặc chọn ảnh toa thuốc" 
                      : "Danh sách thuốc trống.\nHãy thử chụp lại hoặc tự thêm thuốc.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  )
                )
              : ListView.builder(
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final item = _medicines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Text("${index + 1}", style: TextStyle(color: Colors.blue[800])),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.dosage.isNotEmpty) 
                              Text("SL: ${item.dosage}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            if (item.frequency.isNotEmpty) 
                              Text("HDSD: ${item.frequency}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        // --- [MỚI] NÚT SỬA VÀ XÓA ---
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showMedicineDialog(index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMedicine(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveToFirestore,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("LƯU VÀO HỒ SƠ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}