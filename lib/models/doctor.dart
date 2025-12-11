import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String title;
  final int experience;
  final String address;
  final String imageUrl;
  final List<String> specialties;
  final String bio;
  final String? hospital; // Bệnh viện làm việc
  final String? phone;
  final String? email;
  final bool isVerified; // Xác thực bác sĩ
  final Timestamp? createdAt;

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.experience,
    required this.address,
    required this.imageUrl,
    required this.specialties,
    required this.bio,
    this.hospital,
    this.phone,
    this.email,
    this.isVerified = false,
    this.createdAt,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Doctor(
      id: docId,
      name: data['name']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      experience: int.tryParse(data['experience']?.toString() ?? '0') ?? 0,
      address: data['address']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      specialties: (data['specialties'] is List)
          ? List<String>.from(
              (data['specialties'] as List).map((e) => e.toString()),
            )
          : <String>[],
      bio: data['bio']?.toString() ?? '',
      hospital: data['hospital']?.toString(),
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      isVerified: (data['isVerified'] ?? false) as bool,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'experience': experience,
      'address': address,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'bio': bio,
      if (hospital != null) 'hospital': hospital,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'isVerified': isVerified,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? title,
    int? experience,
    String? address,
    String? imageUrl,
    List<String>? specialties,
    String? bio,
    String? hospital,
    String? phone,
    String? email,
    bool? isVerified,
    Timestamp? createdAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      experience: experience ?? this.experience,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      specialties: specialties ?? this.specialties,
      bio: bio ?? this.bio,
      hospital: hospital ?? this.hospital,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
