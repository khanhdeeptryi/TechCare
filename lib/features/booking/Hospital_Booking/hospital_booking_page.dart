import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/hospital.dart';
import '../../../widgets/hospital_card.dart';
import 'hospital_booking_screen.dart'; // File bước 4

class HospitalBookingPage extends StatelessWidget {
  const HospitalBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt khám Bệnh viện')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final hospital = Hospital.fromFirestore(docs[index].data() as Map<String, dynamic>, docs[index].id);
              return HospitalCard(
                hospital: hospital,
                onTap: () => Get.to(() => HospitalBookingScreen(hospital: hospital)),
              );
            },
          );
        },
      ),
    );
  }
}