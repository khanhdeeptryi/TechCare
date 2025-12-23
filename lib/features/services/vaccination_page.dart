import 'package:flutter/material.dart';

class VaccinationPage extends StatelessWidget {
  const VaccinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt lịch Tiêm chủng"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines, size: 80, color: Colors.pink[200]),
            const SizedBox(height: 20),
            const Text("Chức năng đang phát triển", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Quay lại"),
            )
          ],
        ),
      ),
    );
  }
}