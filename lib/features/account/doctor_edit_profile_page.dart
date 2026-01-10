import 'dart:io'; // Để xử lý File ảnh
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Storage
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:tech_care/models/doctor.dart';

class DoctorEditProfilePage extends StatefulWidget {
  final String docId;
  final Doctor? doctor;

  const DoctorEditProfilePage({super.key, required this.docId, this.doctor});

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _expController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _specialtiesController;

  // --- [MỚI] Biến quản lý ảnh ---
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage; // Ảnh mới chọn
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn dữ liệu cũ
    _nameController = TextEditingController(text: widget.doctor?.name ?? '');
    _titleController = TextEditingController(text: widget.doctor?.title ?? '');
    _expController = TextEditingController(text: widget.doctor?.experience.toString() ?? '');
    _addressController = TextEditingController(text: widget.doctor?.address ?? '');
    _bioController = TextEditingController(text: widget.doctor?.bio ?? '');
    _specialtiesController = TextEditingController(text: widget.doctor?.specialties.join(", ") ?? '');
  }

  // --- [MỚI] HÀM CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn ảnh: $e");
    }
  }

  // --- [MỚI] HÀM UPLOAD ẢNH LÊN STORAGE ---
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      File file = File(_selectedImage!.path);
      // Tên file: doctors/profile_images/{docId}.jpg (Ghi đè ảnh cũ luôn cho gọn)
      String fileName = '${widget.docId}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('doctors/profile_images/$fileName');

      UploadTask task = ref.putFile(file);
      TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Lỗi upload: $e");
      rethrow;
    }
  }

  // --- HÀM LƯU DỮ LIỆU ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Upload ảnh trước (nếu có ảnh mới)
      String? newImageUrl;
      if (_selectedImage != null) {
        newImageUrl = await _uploadImage();
      }

      // 2. Xử lý chuỗi chuyên khoa
      List<String> specs = _specialtiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 3. Tạo Map dữ liệu update
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'title': _titleController.text.trim(),
        'experience': int.tryParse(_expController.text) ?? 0,
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
        'specialties': specs,
      };

      // Chỉ cập nhật URL ảnh nếu có ảnh mới
      if (newImageUrl != null) {
        updateData['imageUrl'] = newImageUrl;
      }

      // 4. Lưu lên Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.docId)
          .set(updateData, SetOptions(merge: true));

      Get.back();
      Get.snackbar("Thành công", "Đã cập nhật hồ sơ bác sĩ", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic hiển thị ảnh: Ưu tiên ảnh mới chọn -> Ảnh cũ trên mạng -> Placeholder
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else if (widget.doctor?.imageUrl != null && widget.doctor!.imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(widget.doctor!.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật thông tin"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- [MỚI] KHU VỰC AVATAR CÓ NÚT EDIT ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: imageProvider,
                      child: imageProvider == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.blue) 
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage, // Bấm vào đây để chọn ảnh
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField("Họ và tên", _nameController, Icons.person, "Vui lòng nhập tên"),
              const SizedBox(height: 16),
              
              _buildTextField("Chức danh (VD: ThS. BS)", _titleController, Icons.badge, "Vui lòng nhập chức danh"),
              const SizedBox(height: 16),
              
              _buildTextField("Số năm kinh nghiệm", _expController, Icons.star, "Nhập số năm", isNumber: true),
              const SizedBox(height: 16),
              
              _buildTextField("Nơi công tác", _addressController, Icons.local_hospital, "Nhập địa chỉ làm việc"),
              const SizedBox(height: 16),
              
              _buildTextField("Chuyên khoa (cách nhau dấu phẩy)", _specialtiesController, Icons.category, "VD: Tim mạch, Nhi khoa"),
              const SizedBox(height: 16),
              
              _buildTextField("Giới thiệu bản thân", _bioController, Icons.description, "Mô tả ngắn về bản thân", maxLines: 5),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String? errorMsg, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return errorMsg; 
        }
        return null;
      },
    );
  }
}