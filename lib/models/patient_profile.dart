// File: lib/models/patient_profile.dart

class PatientProfile {
  final String id;
  final String fullName;
  final String gender;
  final String dob;   // dùng String 'dd/MM/yyyy'
  final String phone;
  final bool isDefault; // ✅ dùng để đánh dấu hồ sơ mặc định

  PatientProfile({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.phone,
    this.isDefault = false,
  });

  /// Tạo từ Firestore (Map + docId)
  factory PatientProfile.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return PatientProfile(
      id: docId,
      fullName: data['fullName']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      dob: data['dob']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      isDefault: (data['isDefault'] ?? false) as bool,
    );
  }

  /// Convert ngược lại để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  /// Dùng trong form sửa hồ sơ: tạo bản copy đã chỉnh sửa
  PatientProfile copyWith({
    String? id,
    String? fullName,
    String? gender,
    String? dob,
    String? phone,
    bool? isDefault,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
