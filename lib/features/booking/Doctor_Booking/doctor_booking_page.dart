import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/doctor.dart';
import '../../../widgets/doctor_card.dart';
import 'booking_screen.dart';

class DoctorBookingPage extends StatefulWidget {
  const DoctorBookingPage({super.key});

  @override
  State<DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<DoctorBookingPage> {
  static const String _collectionName = 'doctors';

  // filter state
  String? _selectedLocation;   // ví dụ: "Quận 10"
  String? _selectedSpecialty;  // ví dụ: "nội"

  // bạn chỉnh danh sách này cho khớp với data thật
  final List<String> _locationOptions = [
    'Quận 1',
    'Quận 5',
    'Quận 10',
    'Quận Phú Nhuận',
    'Quận Bình Thạnh',
  ];

  final List<String> _specialtyOptions = [
    'nội',
    'ngoại',
    'Nội thận',
    'Ngoại tiết niệu',
    'Nam khoa',
  ];

  @override
  Widget build(BuildContext context) {
    // Debug: in ra thông tin Firebase hiện tại (1 lần)
    final app = Firebase.app();
    print(' Firebase app name   : ${app.name}');
    print(' Firebase projectId  : ${app.options.projectId}');
    print(' Firebase appId      : ${app.options.appId}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_collectionName)
                  .snapshots(),
              builder: (context, snapshot) {
                print(
                    'snapshot.connectionState = ${snapshot.connectionState}');
                print('snapshot.hasError = ${snapshot.hasError}');
                print('snapshot.hasData = ${snapshot.hasData}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Không có dữ liệu từ Firestore.'),
                  );
                }

                final docs = snapshot.data!.docs;
                print('👉 Tổng số bác sĩ lấy được: ${docs.length}');

                // map sang list Doctor
                List<Doctor> doctors = docs.map((docSnap) {
                  final data =
                      docSnap.data() as Map<String, dynamic>;
                  final docId = docSnap.id;
                  return Doctor.fromFirestore(data, docId);
                }).toList();

                // áp dụng filter location
                if (_selectedLocation != null &&
                    _selectedLocation!.isNotEmpty) {
                  doctors = doctors
                      .where((d) =>
                          d.address.contains(_selectedLocation!))
                      .toList();
                }

                // áp dụng filter specialty
                if (_selectedSpecialty != null &&
                    _selectedSpecialty!.isNotEmpty) {
                  doctors = doctors
                      .where((d) => d.specialties
                          .map((e) => e.toLowerCase())
                          .contains(_selectedSpecialty!.toLowerCase()))
                      .toList();
                }

                print(
                    '👉 Số bác sĩ sau khi lọc: ${doctors.length} (location=$_selectedLocation, specialty=$_selectedSpecialty)');

                if (doctors.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy bác sĩ nào.'),
                  );
                }

                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(
                      doctor: doctor,
                      onBookPressed: () {
                        Get.to(() => BookingScreen(doctor: doctor));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- UI PHẦN TRÊN -----------------

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Tên bác sĩ, triệu chứng, chuyên khoa',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        ),
        // TODO: bạn có thể thêm search theo tên ở đây
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chip Tất cả – xoá hết filter
          ActionChip(
            avatar: const Icon(Icons.menu, size: 18),
            label: const Text('Tất cả'),
            onPressed: () {
              setState(() {
                _selectedLocation = null;
                _selectedSpecialty = null;
              });
            },
            shape: const StadiumBorder(),
          ),

          // Chip Nơi khám – chọn location
          ActionChip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(
              _selectedLocation == null
                  ? 'Nơi khám: Tất cả'
                  : 'Nơi khám: $_selectedLocation',
            ),
            onPressed: _openLocationFilter,
            shape: const StadiumBorder(),
          ),

          // Chip Bộ lọc – chọn chuyên khoa
          ActionChip(
            avatar: const Icon(Icons.filter_list, size: 18),
            label: Text(
              _selectedSpecialty == null
                  ? 'Bộ lọc'
                  : 'Chuyên khoa: $_selectedSpecialty',
            ),
            onPressed: _openSpecialtyFilter,
            shape: const StadiumBorder(),
          ),
        ],
      ),
    );
  }

  // ----------------- BOTTOM SHEET FILTER -----------------

  void _openLocationFilter() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Chọn nơi khám',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Tất cả'),
                onTap: () {
                  setState(() {
                    _selectedLocation = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ..._locationOptions.map((loc) {
                final selected = _selectedLocation == loc;
                return ListTile(
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(loc),
                  onTap: () {
                    setState(() {
                      _selectedLocation = loc;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openSpecialtyFilter() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Chọn chuyên khoa',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Tất cả'),
                onTap: () {
                  setState(() {
                    _selectedSpecialty = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ..._specialtyOptions.map((sp) {
                final selected = _selectedSpecialty == sp;
                return ListTile(
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(sp),
                  onTap: () {
                    setState(() {
                      _selectedSpecialty = sp;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
