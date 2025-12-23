import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'hospital_appointment_list_widget.dart'; 

class HospitalScheduleTab extends StatefulWidget {
  const HospitalScheduleTab({super.key});
  @override
  State<HospitalScheduleTab> createState() => _HospitalScheduleTabState();
}

class _HospitalScheduleTabState extends State<HospitalScheduleTab> {
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[800])
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[50], foregroundColor: Colors.indigo[800], elevation: 0),
              )
            ],
          ),
        ),
        Expanded(
          child: HospitalAppointmentListWidget(
            selectedDate: _selectedDate,
            isDashboard: false, // Để tự cuộn
          ),
        ),
      ],
    );
  }
}