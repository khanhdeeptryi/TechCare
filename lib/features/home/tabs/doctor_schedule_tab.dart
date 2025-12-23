import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_care/features/home/widgets/appointment_list_widget.dart';

class DoctorScheduleTab extends StatefulWidget {
  const DoctorScheduleTab({super.key});

  @override
  State<DoctorScheduleTab> createState() => _DoctorScheduleTabState();
}

class _DoctorScheduleTabState extends State<DoctorScheduleTab> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header chọn ngày
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lịch làm việc", style: TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    ],
                  )
                ],
              ),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Chọn ngày"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[800],
                  elevation: 0,
                ),
              )
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          // Gọi Widget danh sách tái sử dụng
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                AppointmentListWidget(selectedDate: _selectedDate),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}