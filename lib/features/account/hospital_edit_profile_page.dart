import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_care/models/hospital.dart'; // Import model Hospital

class HospitalEditProfilePage extends StatefulWidget {
  final String uid;
  final Hospital? hospital;

  const HospitalEditProfilePage({super.key, required this.uid, this.hospital});

  @override
  State<HospitalEditProfilePage> createState() => _HospitalEditProfilePageState();
}

class _HospitalEditProfilePageState extends State<HospitalEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _name;
  late TextEditingController _address;
  late TextEditingController _hotline;
  late TextEditingController _website;
  late TextEditingController _departments; // Chuyên khoa
  late TextEditingController _description;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.hospital?.name ?? '');
    _address = TextEditingController(text: widget.hospital?.address ?? '');
    _hotline = TextEditingController(text: widget.hospital?.hotline ?? '');
    _website = TextEditingController(text: widget.hospital?.website ?? '');
    _description = TextEditingController(text: widget.hospital?.description ?? '');
    _departments = TextEditingController(text: widget.hospital?.departments.join(", ") ?? '');
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      File file = File(_selectedImage!.path);
      String fileName = '${widget.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('hospitals/logos/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? newImageUrl;
      if (_selectedImage != null) {
        newImageUrl = await _uploadImage();
      }

      List<String> deptList = _departments.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      Map<String, dynamic> data = {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'hotline': _hotline.text.trim(),
        'website': _website.text.trim(),
        'description': _description.text.trim(),
        'departments': deptList,
      };

      if (newImageUrl != null) data['imageUrl'] = newImageUrl;

      await FirebaseFirestore.instance.collection('hospitals').doc(widget.uid).set(data, SetOptions(merge: true));

      Get.back();
      Get.snackbar("Thành công", "Đã cập nhật thông tin bệnh viện", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _selectedImage = img);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else if (widget.hospital?.imageUrl != null && widget.hospital!.imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(widget.hospital!.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cập nhật Bệnh viện"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo),
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: imageProvider == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.add_a_photo, size: 50, color: Colors.indigo), Text("Thêm ảnh Bệnh viện")],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _field("Tên bệnh viện", _name, Icons.apartment),
              _field("Địa chỉ", _address, Icons.location_on),
              _field("Hotline Cấp cứu/CSKH", _hotline, Icons.phone, isNum: true),
              _field("Website", _website, Icons.language),
              _field("Chuyên khoa (cách nhau dấu phẩy)", _departments, Icons.category, hint: "VD: Nội, Ngoại, Sản, Nhi"),
              _field("Giới thiệu chung", _description, Icons.description, maxLines: 4),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, {bool isNum = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNum ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        validator: (val) => val!.isEmpty ? "Vui lòng nhập thông tin" : null,
      ),
    );
  }
}