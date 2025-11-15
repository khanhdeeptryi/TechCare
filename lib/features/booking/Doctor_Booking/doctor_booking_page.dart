import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/doctor.dart';
import '../../../widgets/doctor_card.dart';
import 'booking_screen.dart';

class DoctorBookingPage extends StatelessWidget {
  const DoctorBookingPage({Key? key}) : super(key: key);

  static const String _collectionName = 'doctors';

  @override
  Widget build(BuildContext context) {
    // Debug: in ra thông tin Firebase hiện tại
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
                print('👉 Số lượng bác sĩ lấy được: ${docs.length}');

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy bác sĩ nào.'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final docSnap = docs[index];
                    final data =
                        docSnap.data() as Map<String, dynamic>;
                    final docId = docSnap.id;

                    try {
                      final doctor =
                          Doctor.fromFirestore(data, docId);

                      return DoctorCard(
                        doctor: doctor,
                        onBookPressed: () {
                          Get.to(() => BookingScreen(doctor: doctor));
                        },
                      );
                    } catch (e, st) {
                      print('❌ Lỗi parse Doctor (docId=$docId): $e');
                      print(st);
                      return ListTile(
                        title:
                            Text('Lỗi dữ liệu bác sĩ (id: $docId)'),
                        subtitle: Text(e.toString()),
                      );
                    }
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
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Tên bác sĩ, triệu chứng, chuyên khoa',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionChip(
            avatar: const Icon(Icons.menu, size: 18),
            label: const Text('Tất cả'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),
          ActionChip(
            avatar: const Icon(Icons.add_location_outlined, size: 18),
            label: const Text('Nơi khám: Bác sĩ'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),
          ActionChip(
            avatar: const Icon(Icons.filter_list, size: 18),
            label: const Text('Bộ lọc'),
            onPressed: () {},
            shape: const StadiumBorder(),
          ),
        ],
      ),
    );
  }
}
