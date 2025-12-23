import 'package:flutter/material.dart';
import 'package:tech_care/features/account/account.dart';
import 'package:tech_care/features/chat/doctor_conversation_list_page.dart';
import 'package:tech_care/features/home/tabs/doctor_dashboard_tab.dart'; // Tab 1
import 'package:tech_care/features/home/tabs/doctor_schedule_tab.dart'; // Tab 2
import 'package:tech_care/features/home/tabs/doctor_patient_list_tab.dart'; // Tab 4
import 'package:tech_care/features/account/doctor_account_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const DoctorDashboardTab();
      case 1:
        return const DoctorScheduleTab();
      case 2:
        return DoctorConversationListPage();
      case 3:
        return const DoctorPatientListTab();
      case 4:
        return const DoctorAccountPage();
      default:
        return const DoctorDashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _getPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bệnh nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}