import 'package:flutter/material.dart';
import 'package:tech_care/features/account/clinic_account_page.dart';
import 'package:tech_care/features/chat/doctor_conversation_list_page.dart'; 

// Import các tab vừa tách
import 'features/home/clinic/clinic_dashboard_tab.dart';
import 'features/home/clinic/clinic_schedule_tab.dart';
import 'features/home/clinic/clinic_patient_list_tab.dart';

class ClinicHomePage extends StatefulWidget {
  const ClinicHomePage({super.key});

  @override
  State<ClinicHomePage> createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ClinicDashboardTab(),       // Tab 0
    const ClinicScheduleTab(),        // Tab 1
    DoctorConversationListPage(),     // Tab 2 (Chat)
    const ClinicPatientListTab(),     // Tab 3
    const ClinicAccountPage(),        // Tab 4
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
        selectedItemColor: Colors.teal[800],
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