// File: features/booking/doctor_booking_page.dart
import 'package:flutter/material.dart';

class HospitalBookingPage extends StatelessWidget {
  const HospitalBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt khám Bác sĩ')),
      body: const Center(
        child: Text('Đây là trang đặt khám Bác sĩ'),
      ),
    );
  }
}