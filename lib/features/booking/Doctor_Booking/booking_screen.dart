import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Import các model và repo (Đảm bảo đường dẫn đúng)
import '../../../models/doctor.dart'; // Hoặc doctor.dart tùy tên file bạn đặt
import '../../../models/patient_profile.dart';
import '../../../repositories/patient_profile_repository.dart';

// Import màn hình xác nhận
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _profileRepo = PatientProfileRepository();

  PatientProfile? _selectedProfile;
  bool _isLoadingProfile = true;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;

  // Danh sách khung giờ
  final List<String> _morningSlots = [
    "08:00-08:10", "08:10-08:20", "08:20-08:30", "08:30-08:40", "08:40-08:50", "08:50-09:00",
    "09:00-09:10", "09:10-09:20", "09:20-09:30", "09:30-09:40", "09:40-09:50", "09:50-10:00",
  ];

  final List<String> _afternoonSlots = [
    "17:30-17:40", "17:40-17:50", "17:50-18:00", "18:00-18:10", "18:10-18:20", "18:20-18:30",
    "18:30-18:40", "18:40-18:50", "18:50-19:00", "19:00-19:10", "19:10-19:20", "19:20-19:30",
  ];

  Set<String> _bookedSlots = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Intl.defaultLocale = 'vi_VN';
    _loadDefaultProfile();
    _loadBookedSlotsForSelectedDay();
  }

  // --- LOAD DATA ---

  Future<void> _loadDefaultProfile() async {
    try {
      final p = await _profileRepo.getDefaultProfile();
      if (mounted) {
        setState(() {
          _selectedProfile = p;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Lỗi load default profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(DateTime(date.year, date.month, date.day));
  }

  Future<void> _loadBookedSlotsForSelectedDay() async {
    if (_selectedDay == null) return;

    // Reset lại danh sách đã đặt trước khi load
    setState(() {
      _bookedSlots.clear();
    });

    try {
      // 1. Lấy tất cả lịch hẹn của bác sĩ này
      // (Lưu ý: Để tối ưu hơn, sau này bạn nên query theo range ngày (startAt, endAt)
      // để không phải load toàn bộ lịch sử, nhưng cách này sẽ chạy được ngay mà không cần tạo Index)
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctor.id)
          // Chỉ lấy những đơn đã confirm hoặc completed (tránh đơn đã hủy)
          .where('status', whereIn: ['confirmed', 'completed']) 
          .get();

      final booked = <String>{};

      // 2. Duyệt qua từng lịch hẹn để lọc
      for (var doc in snap.docs) {
        final data = doc.data();
        
        // Lấy thời gian và slot
        final Timestamp? timestamp = data['appointmentTime'];
        final String? slot = data['timeSlot']; // Đảm bảo bạn đã lưu field này ở ConfirmationScreen

        if (timestamp != null && slot != null) {
          final dateFromDb = timestamp.toDate();
          
          // 3. So sánh: Nếu ngày trong DB trùng với ngày đang chọn trên lịch
          if (isSameDay(dateFromDb, _selectedDay)) {
            booked.add(slot);
          }
        }
      }

      print("Các slot đã đặt ngày ${_selectedDay.toString()}: $booked");

      // 4. Cập nhật giao diện
      if (mounted) {
        setState(() {
          _bookedSlots = booked;
          
          // Nếu slot người dùng đang chọn bỗng nhiên bị người khác đặt mất -> bỏ chọn nó
          if (_selectedTimeSlot != null && _bookedSlots.contains(_selectedTimeSlot!)) {
            _selectedTimeSlot = null;
          }
        });
      }
    } catch (e) {
      print('[Booking] Lỗi load booked slots: $e');
    }
  }

  // --- HÀNH ĐỘNG CHÍNH (ĐIỀU HƯỚNG) ---

  void _onContinue() {
    // 1. Validate
    if (_selectedDay == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ khám')),
      );
      return;
    }
    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hồ sơ bệnh nhân')),
      );
      return;
    }

    // 2. Chuyển sang màn hình xác nhận
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          doctor: widget.doctor,
          patientProfile: _selectedProfile!,
          selectedDate: _selectedDay!,
          selectedTimeSlot: _selectedTimeSlot!,
        ),
      ),
    );
  }

  // --- GIAO DIỆN (BUILD) ---

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt lịch: ${doctor.name}'),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepper(),
            _buildDoctorInfoCard(doctor),
            _buildSection(
              title: 'Giới thiệu bác sĩ',
              child: _buildDoctorIntro(doctor),
            ),
            _buildSection(
              title: 'Đặt lịch khám này cho:',
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPatientCard(),
            ),
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
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildContinueButton(),
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text(
            '① Chọn lịch khám',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          Text('② Xác nhận', style: TextStyle(color: Colors.grey)),
          Text('③ Nhận lịch hẹn', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: doctor.imageUrl.isNotEmpty ? NetworkImage(doctor.imageUrl) : null,
            backgroundColor: Colors.grey[200],
            child: doctor.imageUrl.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${doctor.title} ${doctor.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                if (doctor.specialties.isNotEmpty)
                  Text(
                    'Chuyên khoa: ${doctor.specialties.join(", ")}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                const SizedBox(height: 4),
                if (doctor.address.isNotEmpty)
                  Text(
                    doctor.address,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorIntro(Doctor doctor) {
    // Placeholder cho phần giới thiệu (nếu doctor model có field bio thì dùng)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ${doctor.title} ${doctor.name} có nhiều năm kinh nghiệm...'),
        const SizedBox(height: 8),
        const Text('• Vui lòng chọn ngày và khung giờ phù hợp.'),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
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
              Container(width: 4, height: 16, color: Colors.blue, margin: const EdgeInsets.only(right: 8)),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    if (_selectedProfile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chưa có hồ sơ nào.'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _onChooseOrCreateProfile, child: const Text('Tạo hồ sơ')),
        ],
      );
    }

    final p = _selectedProfile!;
    return Column(
      children: [
        _rowField('Họ và tên', p.fullName),
        const SizedBox(height: 8),
        _rowField('Giới tính', p.gender),
        const SizedBox(height: 8),
        _rowField('Ngày sinh', p.dob),
        const SizedBox(height: 8),
        _rowField('Điện thoại', p.phone),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: _onEditProfile, child: const Text('Sửa hồ sơ')),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_forward_ios, size: 14),
              label: const Text('Chọn hoặc tạo hồ sơ khác'),
              onPressed: _onChooseOrCreateProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _rowField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  // --- LOGIC Profile ---
  Future<void> _onEditProfile() async {
    if (_selectedProfile == null) return;
    final updated = await Navigator.push<PatientProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => _PatientProfileFormScreen(repo: _profileRepo, profile: _selectedProfile!),
      ),
    );
    if (updated != null) setState(() => _selectedProfile = updated);
  }

  Future<void> _onChooseOrCreateProfile() async {
    final chosen = await Navigator.push<PatientProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => _PatientProfileSelectionScreen(repo: _profileRepo),
      ),
    );
    if (chosen != null) setState(() => _selectedProfile = chosen);
  }

  // --- DATE & TIME PICKER ---
  Widget _buildDatePicker() {
    return TableCalendar(
      locale: 'vi_VN',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {CalendarFormat.month: 'Tháng'},
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedTimeSlot = null;
        });
        _loadBookedSlotsForSelectedDay();
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
      ),
      headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_morningSlots.isNotEmpty) ...[
          const Text('Buổi sáng', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _morningSlots.map((time) => _buildTimeSlotChip(time)).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_afternoonSlots.isNotEmpty) ...[
          const Text('Buổi chiều', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _afternoonSlots.map((time) => _buildTimeSlotChip(time)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlotChip(String time) {
    final isSelected = _selectedTimeSlot == time;
    final isBooked = _bookedSlots.contains(time);
    final bool isAvailable = !isBooked;

    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isBooked ? Colors.red : (isSelected ? Colors.white : Colors.black),
        decoration: isBooked ? TextDecoration.lineThrough : TextDecoration.none,
      ),
      backgroundColor: isBooked ? Colors.red.shade50 : Colors.grey[100],
      disabledColor: Colors.red.shade100,
      onSelected: isAvailable
          ? (selected) {
              setState(() {
                _selectedTimeSlot = selected ? time : null;
              });
            }
          : null,
    );
  }

  Widget _buildOptionalInfo() {
    return InkWell(
      onTap: () {},
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
    final canContinue = _selectedDay != null && _selectedTimeSlot != null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: canContinue ? _onContinue : null,
        child: const Text('Tiếp tục', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

// --- SUB SCREENS CHO PROFILE (Giữ nguyên để file chạy được) ---

class _PatientProfileFormScreen extends StatefulWidget {
  final PatientProfileRepository repo;
  final PatientProfile? profile;
  const _PatientProfileFormScreen({Key? key, required this.repo, this.profile}) : super(key: key);

  @override
  State<_PatientProfileFormScreen> createState() => _PatientProfileFormScreenState();
}

class _PatientProfileFormScreenState extends State<_PatientProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _genderCtrl, _dobCtrl, _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _genderCtrl = TextEditingController(text: p?.gender ?? 'Nam');
    _dobCtrl = TextEditingController(text: p?.dob ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _genderCtrl.dispose(); _dobCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.profile == null) {
        final temp = PatientProfile(id: '', fullName: _nameCtrl.text.trim(), gender: _genderCtrl.text.trim(), dob: _dobCtrl.text.trim(), phone: _phoneCtrl.text.trim(), isDefault: true);
        final newId = await widget.repo.createProfile(temp);
        await widget.repo.setDefaultProfile(newId);
        if (mounted) Navigator.pop(context, temp.copyWith(id: newId));
      } else {
        final updated = widget.profile!.copyWith(fullName: _nameCtrl.text.trim(), gender: _genderCtrl.text.trim(), dob: _dobCtrl.text.trim(), phone: _phoneCtrl.text.trim());
        await widget.repo.updateProfile(updated);
        if (mounted) Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi lưu hồ sơ')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.profile == null ? 'Tạo hồ sơ' : 'Sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên'), validator: (v) => v!.isEmpty ? 'Nhập tên' : null),
              TextFormField(controller: _genderCtrl, decoration: const InputDecoration(labelText: 'Giới tính')),
              TextFormField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'Ngày sinh')),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Điện thoại')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saving ? null : _onSave, child: _saving ? const CircularProgressIndicator() : const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientProfileSelectionScreen extends StatelessWidget {
  final PatientProfileRepository repo;
  const _PatientProfileSelectionScreen({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn hồ sơ')),
      body: StreamBuilder<List<PatientProfile>>(
        stream: repo.streamProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final profiles = snapshot.data ?? [];
          if (profiles.isEmpty) return const Center(child: Text('Chưa có hồ sơ'));
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final p = profiles[index];
              return ListTile(
                title: Text(p.fullName),
                subtitle: Text(p.phone),
                trailing: p.isDefault ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  await repo.setDefaultProfile(p.id);
                  Navigator.pop(context, p);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<PatientProfile>(context, MaterialPageRoute(builder: (_) => _PatientProfileFormScreen(repo: repo)));
          if (created != null) Navigator.pop(context, created);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}