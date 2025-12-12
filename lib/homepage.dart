import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_care/features/authenticate/login.dart';
import 'package:tech_care/features/account/account.dart';
import 'package:tech_care/features/booking/Doctor_Booking/doctor_booking_page.dart';
import 'package:tech_care/features/booking/Clinic_Booking/clinic_booking_page.dart';
import 'package:tech_care/features/booking/Hospital_Booking/hospital_booking_page.dart';
import 'package:tech_care/features/health_profile/health_profile_page.dart';
import 'package:tech_care/features/appointments/patient_appointment_list_page.dart'; // Sửa đường dẫn nếu cần

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}


class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const PatientAppointmentListPage();
      case 2:
        return Center(child: Text('Trợ lý y khoa', style: TextStyle(fontSize: 24)));
      case 3:
        return Center(child: Text('Tin nhắn', style: TextStyle(fontSize: 24)));
      case 4:
        return Account();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        // Header (Không đổi)
        Container(
          color: Colors.blue,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buổi tối an lành!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (user == null) {
                              Get.to(Login());
                            }
                          },
                          child: Text(
                            user != null ? user!.email! : 'Đăng ký / Đăng nhập',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tên bác sĩ, triệu chứng bệnh, chuyên khoa...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),

                // Banner slider (Không đổi)
                Container(
                  height: 160,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: PageView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.lightBlue[100]!, Colors.lightBlue[50]!],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.health_and_safety, color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Dịch vụ tư vấn chính thống',
                                        style: TextStyle(fontSize: 12, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'ĐẶT CÂU HỎI MIỄN PHÍ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  Text(
                                    'VỚI BÁC SĨ',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '& CHUYÊN GIA DINH DƯỠNG',
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // --- BƯỚC 3: CẬP NHẬT GRID CÁC CHỨC NĂNG ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            Icons.medical_services,
                            'Đặt khám\nbác sĩ',
                            Colors.orange,
                            // Thêm hành động onTap
                            () => Get.to(() => DoctorBookingPage()),
                          ),
                          _buildFeatureItem(
                            Icons.local_hospital,
                            'Đặt khám\nphòng khám',
                            Colors.blue,
                           () => Get.to(() => ClinicBookingPage()),
                          ),
                          _buildFeatureItem(
                            Icons.business,
                            'Đặt khám\nbệnh viện',
                            Colors.pink,
                            () => Get.to(() => HospitalBookingPage()),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            Icons.chat_bubble,
                            'Chat với\nbác sĩ',
                            Colors.cyan,
                            // () => Get.to(() => ChatPage()),
                            () {}, // Tạm thời
                          ),
                          _buildFeatureItem(
                            Icons.video_call,
                            'Gọi video\nvới bác sĩ',
                            Colors.purple,
                            // () => Get.to(() => VideoCallPage()),
                            () {}, // Tạm thời
                          ),
                          _buildFeatureItem(
                              Icons.favorite,
                              'Hồ sơ\nsức khỏe',
                            Colors.cyan,
                              // 3. Cập nhật dòng này:
                              () => Get.to(() => const HealthProfilePage()), 
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            Icons.vaccines,
                            'Đặt lịch\nTiêm chủng',
                            Colors.pink,
                            // () => Get.to(() => VaccinationPage()),
                            () {}, // Tạm thời
                          ),
                          _buildFeatureItem(
                            Icons.science,
                            'Đặt lịch\nXét nghiệm',
                            Colors.cyan,
                            // () => Get.to(() => LabTestPage()),
                            () {}, // Tạm thời
                          ),
                          _buildFeatureItem(
                            Icons.group,
                            'Cộng đồng',
                            Colors.blue,
                            // () => Get.to(() => CommunityPage()),
                            () {}, // Tạm thời
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Card đăng ký thành viên (Không đổi)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đăng ký thành viên',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Trở thành thành viên để trải nghiệm những tiện ích chăm sóc sức khỏe từ YouMed.',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.card_giftcard, color: Colors.amber, size: 50),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (user == null) {
                          Get.to(Login());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'ĐĂNG KÝ NGAY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Bác sĩ section (Không đổi)
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.blue, size: 30),
                      SizedBox(width: 12),
                      Text(
                        'Bác sĩ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),

                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _getPage(),
      ),

      // Bottom Navigation Bar (Không đổi)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch khám',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Trợ lý y khoa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  // --- BƯỚC 2: SỬA ĐỔI _buildFeatureItem ---
  Widget _buildFeatureItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector( // Bọc trong GestureDetector
      onTap: onTap, // Gán hành động onTap
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 35),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}