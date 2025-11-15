import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/doctor.dart';
//import '../../../models/patient_profile.dart'; // Bạn cũng sẽ cần cái này

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  const BookingScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);
  // --------------------------------------------------

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // === QUẢN LÝ TRẠNG THÁI ===
  
  // Dữ liệu này sẽ được load từ Firebase (cho người dùng hiện tại)
  //final PatientProfile _selectedProfile = PatientProfile(
  //  id: "patient_123",
  //  fullName: "Trần Binh Minh",
  //  gender: "Nam",
  //  dob: "26/08/2004",
  //  phone: "0898 784 168",
  //);

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;

  final List<String> _morningSlots = [];
  final List<String> _afternoonSlots = [
    "17:30-17:40", "17:40-17:50", "17:50-18:00",
    "18:00-18:10", "18:10-18:20", "18:20-18:30",
    "18:30-18:40", "18:40-18:50", "18:50-19:00",
    "19:00-19:10", "19:10-19:20", "19:20-19:30",
  ];
  // ========================

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Intl.defaultLocale = 'vi_VN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Giờ bạn có thể dùng thông tin bác sĩ ở đây
        title: Text('Đặt lịch: ${widget.doctor.name}'),
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Hỗ trợ', style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepper(), // Thanh tiến trình 1 - 2 - 3
            // --- SỬ DỤNG widget.doctor ---
            // Truyền thông tin bác sĩ vào hàm _buildDoctorInfoCard
            //_buildDoctorInfoCard(widget.doctor),
            //_buildSection(
            // title: 'Đặt lịch khám này cho:',
            //  child: _buildPatientCard(),
            //),
            _buildSection(
              title: 'Chọn ngày khám',
              child: _buildDatePicker(),
            ),
            _buildSection(
              title: 'Chọn giờ khám (12 khung giờ)',
              child: _buildTimePicker(),
            ),
            _buildSection(
              title: 'Thông tin bổ sung (không bắt buộc)',
              child: _buildOptionalInfo(),
            ),
            const SizedBox(height: 100), // Khoảng trống cho nút
          ],
        ),
      ),
      bottomSheet: _buildContinueButton(),
    );
  }

  // === CÁC WIDGET CON ===

  Widget _buildStepper() {
    // (Giữ nguyên code _buildStepper)
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text('① Chọn lịch khám', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          Text('② Xác nhận', style: TextStyle(color: Colors.grey)),
          Text('③ Nhận lịch hẹn', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- SỬA HÀM NÀY ĐỂ NHẬN THAM SỐ DOCTOR ---
  Widget _buildDoctorInfoCard(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(doctor.imageUrl), // Dùng doctor.imageUrl
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${doctor.title} ${doctor.name}', // Dùng doctor.title và doctor.name
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Chuyên khoa: ${doctor.specialties.join(", ")}', // Dùng doctor.specialties
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    // (Giữ nguyên code _buildSection)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 16, 
                color: Colors.blue, 
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
/*
  Widget _buildPatientCard() {
    // (Giữ nguyên code _buildPatientCard)
    // Bạn sẽ dùng StreamBuilder để load hồ sơ từ Firebase
    return Column(
     children: [
        Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
            Text('Họ và tên'), Text(_selectedProfile.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Giới tính'), Text(_selectedProfile.gender, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ngày sinh'), Text(_selectedProfile.dob, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Điện thoại'), Text(_selectedProfile.phone, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () { /* Sửa hồ sơ */ },
              child: Text('Sửa hồ sơ'),
            ),
            OutlinedButton.icon(
              icon: Icon(Icons.arrow_forward_ios, size: 14),
              label: Text('Chọn hoặc tạo hồ sơ khác'),
              onPressed: () { /* Mở danh sách hồ sơ */ },
            ),
          ],
        ),
      ],
    );
  }
*/

  Widget _buildDatePicker() {
    // (Giữ nguyên code _buildDatePicker)
    return TableCalendar(
      locale: 'vi_VN',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Tháng',
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {},
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  Widget _buildTimePicker() {
    // (Giữ nguyên code _buildTimePicker)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_morningSlots.isNotEmpty) ...[
          Text('Buổi sáng', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _morningSlots.map((time) => _buildTimeSlotChip(time)).toList(),
          ),
          SizedBox(height: 16),
        ],
        if (_afternoonSlots.isNotEmpty) ...[
          Text('Buổi chiều', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _afternoonSlots.map((time) => _buildTimeSlotChip(time)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlotChip(String time) {
    // (Giữ nguyên code _buildTimeSlotChip)
    bool isSelected = _selectedTimeSlot == time;
    bool isAvailable = true; 

    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isAvailable ? Colors.black : Colors.grey),
      ),
      backgroundColor: Colors.grey[100],
      disabledColor: Colors.grey[200],
      onSelected: (selected) {
        if (isAvailable) {
          setState(() {
            _selectedTimeSlot = selected ? time : null;
          });
        }
      },
    );
  }
   
  Widget _buildOptionalInfo() {
    // (Giữ nguyên code _buildOptionalInfo)
    return InkWell(
      onTap: () { /* Mở màn hình nhập thông tin */ },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tôi muốn gửi thêm thông tin ...', style: TextStyle(color: Colors.grey[700])),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    // (Giữ nguyên code _buildContinueButton)
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: (_selectedDay == null || _selectedTimeSlot == null)
            ? null 
            : () {
                print('Chuyển sang màn hình 2');
              },
        child: const Text('Tiếp tục', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}