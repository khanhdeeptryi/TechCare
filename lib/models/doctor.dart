class Doctor {
  final String id;
  final String name;
  final String title;       // Ví dụ: ThS. BS, PGS. TS...
  final int experience;     // Số năm kinh nghiệm
  final String address;     // Địa chỉ phòng khám/Bệnh viện
  final String imageUrl;
  final List<String> specialties; // Chuyên khoa
  final String bio;         // Giới thiệu bản thân

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.experience,
    required this.address,
    required this.imageUrl,
    required this.specialties,
    required this.bio,
  });

  // Factory để parse dữ liệu từ Firestore
  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Doctor(
      id: docId,
      name: data['name']?.toString() ?? 'Chưa cập nhật tên',
      title: data['title']?.toString() ?? 'Bác sĩ',
      experience: int.tryParse(data['experience']?.toString() ?? '0') ?? 0,
      address: data['address']?.toString() ?? 'Chưa cập nhật địa chỉ',
      imageUrl: data['imageUrl']?.toString() ?? '',
      specialties: (data['specialties'] is List)
          ? List<String>.from((data['specialties'] as List).map((e) => e.toString()))
          : <String>[],
      bio: data['bio']?.toString() ?? 'Chưa có thông tin giới thiệu.',
    );
  }

  // Hàm chuyển đổi sang Map để lưu lên Firestore (Dùng khi Update)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'experience': experience,
      'address': address,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'bio': bio,
    };
  }
}