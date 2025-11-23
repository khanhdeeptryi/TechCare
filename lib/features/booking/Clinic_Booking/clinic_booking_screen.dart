import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/clinic.dart';
import '../../../models/patient_profile.dart';
import 'clinic_confirmation_screen.dart';
import '../../../repositories/patient_profile_repository.dart';
class ClinicBookingScreen extends StatefulWidget {
  final Clinic clinic;

  const ClinicBookingScreen({
    Key? key,
    required this.clinic,
  }) : super(key: key);

  @override
  State<ClinicBookingScreen> createState() => _ClinicBookingScreenState();
}

class _ClinicBookingScreenState extends State<ClinicBookingScreen> {
  // Calendar
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Slot
  String? _selectedTimeSlot;

  final _profileRepo = PatientProfileRepository();
  PatientProfile? _selectedProfile;
  bool _isLoadingProfile = true;

  // Busy slots map: timeSlot -> isBooked
  final Map<String, bool> _bookedSlots = {};

  // Buổi sáng / chiều
  final List<String> _morningSlots = const [
    "08:00-08:10",
    "08:10-08:20",
    "08:20-08:30",
    "08:30-08:40",
    "08:40-08:50",
    "08:50-09:00",
    "09:00-09:10",
    "09:10-09:20",
    "09:20-09:30",
    "09:30-09:40",
    "09:40-09:50",
    "09:50-10:00",
  ];

  final List<String> _afternoonSlots = const [
    "17:30-17:40",
    "17:40-17:50",
    "17:50-18:00",
    "18:00-18:10",
    "18:10-18:20",
    "18:20-18:30",
    "18:30-18:40",
    "18:40-18:50",
    "18:50-19:00",
    "19:00-19:10",
    "19:10-19:20",
    "19:20-19:30",
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Intl.defaultLocale = 'vi_VN';
    _loadDefaultProfile();
    _loadBookedSlotsForSelectedDay();
  }

  String _dateKey(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month, d.day));

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

  Future<void> _loadBookedSlotsForSelectedDay() async {
    if (_selectedDay == null) return;

    final dateStr = _dateKey(_selectedDay!);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('bookingType', isEqualTo: 'clinic')
          .where('clinicId', isEqualTo: widget.clinic.id)
          .where('date', isEqualTo: dateStr)
          .get();

      final Map<String, bool> booked = {};
      for (final doc in snap.docs) {
        final data = doc.data();
        final slot = data['timeSlot'] as String? ?? '';
        if (slot.isNotEmpty) {
          booked[slot] = true;
        }
      }

      if (mounted) {
        setState(() {
          _bookedSlots
            ..clear()
            ..addAll(booked);
          // Nếu slot đã chọn bị book rồi thì huỷ chọn
          if (_selectedTimeSlot != null &&
              _bookedSlots[_selectedTimeSlot!] == true) {
            _selectedTimeSlot = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi load booked slots clinic: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTimeSlot = null; // reset slot khi đổi ngày
    });
    _loadBookedSlotsForSelectedDay();
  }

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

  void _onContinue() {
    if (_selectedDay == null ||
        _selectedTimeSlot == null ||
        _selectedProfile == null) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn hồ sơ, ngày và khung giờ khám.',
        backgroundColor: Colors.orange.withOpacity(0.4),
        colorText: Colors.black,
      );
      return;
    }

    Get.to(
      () => ClinicConfirmationScreen(
        clinic: widget.clinic,
        patientProfile: _selectedProfile!,
        selectedDate: _selectedDay!,
        selectedTimeSlot: _selectedTimeSlot!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue =
        _selectedDay != null && _selectedTimeSlot != null && _selectedProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt lịch: ${widget.clinic.name}'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildClinicInfoCard(),
                  _buildSection(
                    title: 'Đặt lịch khám này cho:',
                    child: _buildPatientCard(),
                  ),
                  _buildSection(
                    title: 'Chọn ngày khám',
                    child: _buildDatePicker(),
                  ),
                  _buildSection(
                    title: 'Chọn giờ khám',
                    child: _buildTimePicker(),
                  ),
                  _buildSection(
                    title: 'Thông tin bổ sung (không bắt buộc)',
                    child: _buildOptionalInfo(),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving || !canContinue ? null : _onContinue,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  // ================== UI CON ==================

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text(
            '① Chọn lịch khám',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('② Xác nhận', style: TextStyle(color: Colors.grey)),
          Text('③ Nhận lịch hẹn', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildClinicInfoCard() {
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
            backgroundImage: widget.clinic.imageUrl.isNotEmpty
                ? NetworkImage(widget.clinic.imageUrl)
                : null,
            backgroundColor: Colors.grey[200],
            child: widget.clinic.imageUrl.isEmpty
                ? const Icon(Icons.local_hospital, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinic.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.clinic.address,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
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
              Container(
                width: 4,
                height: 16,
                color: Colors.blue,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
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
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {},
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_morningSlots.isNotEmpty) ...[
          const Text(
            'Buổi sáng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                _morningSlots.map((time) => _buildTimeSlotChip(time)).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_afternoonSlots.isNotEmpty) ...[
          const Text(
            'Buổi chiều',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _afternoonSlots
                .map((time) => _buildTimeSlotChip(time))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlotChip(String time) {
    final isSelected = _selectedTimeSlot == time;
    final isBooked = _bookedSlots[time] == true;

    Color bg;
    Color textColor;
    if (isBooked) {
      bg = Colors.red.shade100;
      textColor = Colors.red.shade700;
    } else if (isSelected) {
      bg = Colors.blue;
      textColor = Colors.white;
    } else {
      bg = Colors.grey[100]!;
      textColor = Colors.black;
    }

    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: textColor,
      ),
      backgroundColor: bg,
      onSelected: isBooked
          ? null
          : (selected) {
              setState(() {
                _selectedTimeSlot = selected ? time : null;
              });
            },
    );
  }

  Widget _buildOptionalInfo() {
    return InkWell(
      onTap: () {
        // TODO: mở màn hình nhập thông tin bổ sung nếu cần
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tôi muốn gửi thêm thông tin ...',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }
}


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