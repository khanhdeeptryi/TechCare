import 'package:flutter/material.dart';
import 'package:tech_care/features/account/hospital_account_page.dart';
import 'package:tech_care/features/chat/doctor_conversation_list_page.dart'; 

// Import các tab vừa tách
import 'features/home/hospital/hospital_dashboard_tab.dart';
import 'features/home/hospital/hospital_schedule_tab.dart';
import 'features/home/hospital/hospital_patient_list_tab.dart';

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HospitalDashboardTab(),       // Tab 0
    const HospitalScheduleTab(),        // Tab 1
    DoctorConversationListPage(),       // Tab 2
    const HospitalPatientListTab(),     // Tab 3
    const HospitalAccountPage(),        // Tab 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bệnh nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}