import 'package:flutter/material.dart';

class LabTestPage extends StatelessWidget {
  const LabTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt lịch Xét nghiệm"),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 80, color: Colors.cyan[200]),
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