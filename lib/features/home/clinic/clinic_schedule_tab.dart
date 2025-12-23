import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'clinic_appointment_list_widget.dart'; // Import widget chung

class ClinicScheduleTab extends StatefulWidget {
  const ClinicScheduleTab({super.key});
  @override
  State<ClinicScheduleTab> createState() => _ClinicScheduleTabState();
}

class _ClinicScheduleTabState extends State<ClinicScheduleTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate), 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context, 
                    initialDate: _selectedDate, 
                    firstDate: DateTime(2020), 
                    lastDate: DateTime(2030)
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Chọn ngày"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[50], foregroundColor: Colors.teal[800], elevation: 0),
              )
            ],
          ),
        ),
        // Sử dụng widget chung, truyền ngày được chọn
        Expanded(child: ClinicAppointmentListWidget(selectedDate: _selectedDate, isDashboard: false)),
      ],
    );
  }
}