import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// [QUAN TRỌNG] Import màn hình OCR
import 'package:tech_care/features/patient/patient_upload_record_screen.dart';

class UpdatePersonalInfoPage extends StatefulWidget {
  const UpdatePersonalInfoPage({super.key});

  @override
  State<UpdatePersonalInfoPage> createState() => _UpdatePersonalInfoPageState();
}

class _UpdatePersonalInfoPageState extends State<UpdatePersonalInfoPage> {
  // --- Controller Thông tin cơ bản ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  // --- Controller Pháp lý ---
  final TextEditingController _cccdController = TextEditingController(); 
  final TextEditingController _bhytController = TextEditingController(); 

  // --- Controller Chỉ số ---
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Nam';
  bool _isLoading = false;
  
  // Biến quản lý ảnh (Upload thủ công)
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = []; 
  
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Tải dữ liệu cũ lên
  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => _isLoading = true);

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        _fullNameController.text = data['fullName'] ?? data['name'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _dobController.text = data['dateOfBirth'] ?? '';
        
        _cccdController.text = data['cccd'] ?? '';
        _bhytController.text = data['bhyt'] ?? '';

        _heightController.text = data['height'] ?? '';
        _weightController.text = data['weight'] ?? '';

        if (data['gender'] != null) {
          setState(() {
            _selectedGender = data['gender'];
          });
        }
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Chọn ảnh thủ công
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn ảnh: $e");
    }
  }

  // 3. Xóa ảnh chọn
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 4. Upload ảnh lên Storage
  Future<List<String>> _uploadImagesToStorage() async {
    List<String> downloadUrls = [];
    try {
      for (var xFile in _selectedImages) {
        File file = File(xFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // Lưu vào folder riêng của user
        Reference ref = FirebaseStorage.instance.ref().child('users/${user!.uid}/medical_records/$fileName.jpg');
        
        UploadTask task = ref.putFile(file);
        TaskSnapshot snapshot = await task;
        String url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      }
    } catch (e) {
      print("Lỗi upload: $e");
      throw e; 
    }
    return downloadUrls;
  }

  // 5. Lưu toàn bộ dữ liệu
  Future<void> _saveUserData() async {
    if (user == null) return;
    setState(() => _isLoading = true);

    try {
      // Upload ảnh trước (nếu có)
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        Get.snackbar("Đang xử lý", "Đang tải ảnh hồ sơ lên...", backgroundColor: Colors.blue, colorText: Colors.white);
        newImageUrls = await _uploadImagesToStorage();
      }

      Map<String, dynamic> updateData = {
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'gender': _selectedGender,
        'height': _heightController.text.trim(),
        'weight': _weightController.text.trim(),
        'cccd': _cccdController.text.trim(),
        'bhyt': _bhytController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Nếu có ảnh mới thì thêm vào mảng images
      if (newImageUrls.isNotEmpty) {
        updateData['medicalRecordImages'] = FieldValue.arrayUnion(newImageUrls);
      }

      // Cập nhật Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(updateData);
      
      // Cập nhật Display Name của Auth (để hiện tên đúng ở các màn hình khác)
      await user!.updateDisplayName(_fullNameController.text.trim());

      setState(() { _selectedImages.clear(); });

      Get.snackbar("Thành công", "Đã cập nhật hồ sơ!", backgroundColor: Colors.green, colorText: Colors.white);
      await Future.delayed(const Duration(seconds: 1));
      Get.back(); 

    } catch (e) {
      Get.snackbar("Thất bại", "Lỗi khi lưu: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật thông tin"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 1
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text("Thông tin cơ bản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("Họ và tên", "Nhập họ tên", _fullNameController, Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField("Số điện thoại", "Nhập SĐT", _phoneController, Icons.phone, inputType: TextInputType.phone),
                  const SizedBox(height: 12),
                   Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              items: ['Nam', 'Nữ', 'Khác'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedGender = val!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(child: _buildTextField("Ngày sinh", "dd/mm/yyyy", _dobController, Icons.calendar_today)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24), const Divider(), const SizedBox(height: 10),

                  // --- THÔNG TIN PHÁP LÝ ---
                  const Text("Thông tin pháp lý", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("Số CCCD / CMND", "Nhập số căn cước", _cccdController, Icons.credit_card, inputType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField("Mã số BHYT", "Nhập mã bảo hiểm y tế", _bhytController, Icons.health_and_safety),
                  
                  const SizedBox(height: 24), const Divider(), const SizedBox(height: 10),

                  // --- CHỈ SỐ CƠ THỂ ---
                  const Text("Chỉ số cơ thể", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Chiều cao (cm)", "VD: 170", _heightController, Icons.height, inputType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Cân nặng (kg)", "VD: 65", _weightController, Icons.monitor_weight, inputType: TextInputType.number)),
                    ],
                  ),

                  const SizedBox(height: 24), const Divider(), const SizedBox(height: 10),

                  // --- [KHU VỰC HỒ SƠ BỆNH ÁN] ---
                  const Text("Hồ sơ bệnh án", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  
                  // --- 1. NÚT OCR: QUÉT BỆNH ÁN CŨ (Tính năng mới) ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Chuyển sang màn hình OCR
                        // Dùng Navigator.push thay vì Get.to để tránh lỗi format nếu có
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PatientUploadRecordScreen()),
                        );
                      },
                      icon: const Icon(Icons.document_scanner, color: Colors.white),
                      label: const Text("QUÉT BỆNH ÁN CŨ (OCR)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800], // Màu nổi bật
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  const Center(child: Text("HOẶC", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 12),

                  // --- 2. NÚT UPLOAD ẢNH THỦ CÔNG ---
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.5))),
                      child: Column(children: [Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue[700]), const SizedBox(height: 8), Text("Tải ảnh thủ công (Không trích xuất)", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold))]),
                    ),
                  ),

                  // Hiển thị ảnh thủ công đã chọn
                  if (_selectedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (ctx, idx) => Stack(children: [
                            Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: FileImage(File(_selectedImages[idx].path)), fit: BoxFit.cover))),
                            Positioned(top: 2, right: 10, child: GestureDetector(onTap: () => _removeImage(idx), child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.close, size: 20, color: Colors.red))))
                          ]),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  _buildTextField("Địa chỉ", "Nhập địa chỉ", _addressController, Icons.home),
                  const SizedBox(height: 30),

                  // Nút Lưu chính
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("CẬP NHẬT HỒ SƠ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: Colors.blue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12)),
    );
  }
}