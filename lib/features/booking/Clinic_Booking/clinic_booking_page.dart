import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/clinic.dart';
import '../../../widgets/clinic_card.dart';
import 'clinic_booking_screen.dart'; // File ở bước 4

class ClinicBookingPage extends StatefulWidget {
  const ClinicBookingPage({Key? key}) : super(key: key);

  @override
  State<ClinicBookingPage> createState() => _ClinicBookingPageState();
}

class _ClinicBookingPageState extends State<ClinicBookingPage> {
  static const String _collectionName = 'clinics'; // Collection name trên Firebase

  // Filter state (Tương tự DoctorBookingPage)
  String? _selectedLocation; 

  final List<String> _locationOptions = [
    'Quận 1', 'Quận 5', 'Quận 10', 'Quận Phú Nhuận', 'Quận Bình Thạnh',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(_collectionName).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không tìm thấy phòng khám nào.'));
                }

                final docs = snapshot.data!.docs;
                
                // Map sang list Clinic
                List<Clinic> clinics = docs.map((docSnap) {
                  return Clinic.fromFirestore(
                    docSnap.data() as Map<String, dynamic>, 
                    docSnap.id
                  );
                }).toList();

                // Filter logic
                if (_selectedLocation != null) {
                  clinics = clinics.where((c) => c.address.contains(_selectedLocation!)).toList();
                }

                return ListView.builder(
                  itemCount: clinics.length,
                  itemBuilder: (context, index) {
                    final clinic = clinics[index];
                    return ClinicCard(
                      clinic: clinic,
                      onBookPressed: () {
                        // Điều hướng sang màn hình chọn lịch (ClinicBookingScreen)
                        Get.to(() => ClinicBookingScreen(clinic: clinic));
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm phòng khám, địa chỉ...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.menu, size: 18),
            label: const Text('Tất cả'),
            onPressed: () => setState(() => _selectedLocation = null),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(_selectedLocation == null ? 'Khu vực' : _selectedLocation!),
            onPressed: _openLocationFilter,
          ),
        ],
      ),
    );
  }

  void _openLocationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text("Chọn khu vực", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            ..._locationOptions.map((loc) => ListTile(
              title: Text(loc),
              onTap: () {
                setState(() => _selectedLocation = loc);
                Navigator.pop(context);
              },
            )).toList()
          ],
        );
      },
    );
  }
}