import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_care/models/clinic.dart'; // Import model Clinic

class ClinicEditProfilePage extends StatefulWidget {
  final String uid;
  final Clinic? clinic; // Dữ liệu cũ

  const ClinicEditProfilePage({super.key, required this.uid, this.clinic});

  @override
  State<ClinicEditProfilePage> createState() => _ClinicEditProfilePageState();
}

class _ClinicEditProfilePageState extends State<ClinicEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _name;
  late TextEditingController _address;
  late TextEditingController _hotline;
  late TextEditingController _openHours;
  late TextEditingController _services; // Nhập cách nhau dấu phẩy
  late TextEditingController _description;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.clinic?.name ?? '');
    _address = TextEditingController(text: widget.clinic?.address ?? '');
    _hotline = TextEditingController(text: widget.clinic?.hotline ?? '');
    _openHours = TextEditingController(text: widget.clinic?.openHours ?? '');
    _description = TextEditingController(text: widget.clinic?.description ?? '');
    // Chuyển List thành String
    _services = TextEditingController(text: widget.clinic?.services.join(", ") ?? '');
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      File file = File(_selectedImage!.path);
      String fileName = '${widget.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('clinics/logos/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw e;
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

      List<String> servicesList = _services.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      Map<String, dynamic> data = {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'hotline': _hotline.text.trim(),
        'openHours': _openHours.text.trim(),
        'description': _description.text.trim(),
        'services': servicesList,
      };

      if (newImageUrl != null) data['imageUrl'] = newImageUrl;

      await FirebaseFirestore.instance.collection('clinics').doc(widget.uid).set(data, SetOptions(merge: true));

      Get.back();
      Get.snackbar("Thành công", "Đã cập nhật thông tin phòng khám", backgroundColor: Colors.green, colorText: Colors.white);
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
    } else if (widget.clinic?.imageUrl != null && widget.clinic!.imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(widget.clinic!.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cập nhật Phòng khám"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
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
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: imageProvider == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.add_a_photo, size: 50, color: Colors.teal), Text("Thêm ảnh bìa/Logo")],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _field("Tên phòng khám", _name, Icons.local_hospital),
              _field("Địa chỉ", _address, Icons.location_on),
              _field("Hotline", _hotline, Icons.phone, isNum: true),
              _field("Giờ mở cửa (VD: 08:00 - 20:00)", _openHours, Icons.access_time),
              _field("Dịch vụ (cách nhau dấu phẩy)", _services, Icons.list, hint: "VD: Siêu âm, Xét nghiệm máu"),
              _field("Giới thiệu", _description, Icons.description, maxLines: 4),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: Colors.teal), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        validator: (val) => val!.isEmpty ? "Vui lòng nhập thông tin" : null,
      ),
    );
  }
}