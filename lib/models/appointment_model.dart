import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String bookingType; // 'doctor', 'clinic', 'hospital'
  final String status;
  final Map<String, dynamic> patientProfile;

  // Dữ liệu riêng biệt
  final Map<String, dynamic>? doctorData;
  final Map<String, dynamic>? clinicData;
  final Map<String, dynamic>? hospitalData;

  final Timestamp appointmentTime;
  final Timestamp createdAt;
  final String? doctorId;
  final String? clinicId;
  final String? hospitalId;
  final String date;
  final String timeSlot;
  final ExaminationResult? examinationResult;

  Appointment({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.status,
    required this.patientProfile,
    this.doctorData,
    this.clinicData,
    this.hospitalData,
    required this.appointmentTime,
    required this.createdAt,
    required this.date,
    required this.timeSlot,
    this.doctorId,
    this.clinicId,
    this.hospitalId,
    this.examinationResult,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String documentId) {
    // --- HÀM AN TOÀN ĐỂ PARSE NGÀY GIỜ ---
    // Giúp tránh lỗi FormatException nếu data cũ lưu dạng chuỗi
    Timestamp safeTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      if (value is String) {
        try {
          return Timestamp.fromDate(DateTime.parse(value)); 
        } catch (_) {
          return Timestamp.now(); // Lỗi format thì lấy giờ hiện tại
        }
      }
      return Timestamp.now();
    }

    // --- FALLBACK CHO DỮ LIỆU CŨ ---
    // Tự động tìm dữ liệu cũ và gán vào model mới
    Map<String, dynamic>? fallbackDoctor;
    Map<String, dynamic>? fallbackClinic;
    Map<String, dynamic>? fallbackHospital;

    if (data['doctorData'] == null && data['doctorInfo'] != null) {
      fallbackDoctor = Map<String, dynamic>.from(data['doctorInfo']);
    }
    
    if (data['clinicData'] == null) {
      if (data['clinicInfo'] != null) {
        fallbackClinic = Map<String, dynamic>.from(data['clinicInfo']);
      } else if (data['doctorInfo'] != null && (data['bookingType'] == 'clinic')) {
        fallbackClinic = Map<String, dynamic>.from(data['doctorInfo']);
      }
    }

    if (data['hospitalData'] == null) {
      if (data['hospitalInfo'] != null) {
        fallbackHospital = Map<String, dynamic>.from(data['hospitalInfo']);
      } else if (data['doctorInfo'] != null && (data['bookingType'] == 'hospital')) {
        fallbackHospital = Map<String, dynamic>.from(data['doctorInfo']);
      }
    }

    return Appointment(
      id: documentId,
      userId: data['userId'] ?? '',
      bookingType: data['bookingType'] ?? 'doctor',
      status: data['status'] ?? 'pending',
      patientProfile: Map<String, dynamic>.from(data['patientProfile'] ?? {}),
      
      doctorData: data['doctorData'] != null ? Map<String, dynamic>.from(data['doctorData']) : fallbackDoctor,
      clinicData: data['clinicData'] != null ? Map<String, dynamic>.from(data['clinicData']) : fallbackClinic,
      hospitalData: data['hospitalData'] != null ? Map<String, dynamic>.from(data['hospitalData']) : fallbackHospital,

      // Dùng hàm an toàn
      appointmentTime: safeTimestamp(data['appointmentTime']),
      createdAt: safeTimestamp(data['createdAt']),
      
      doctorId: data['doctorId'],
      clinicId: data['clinicId'],
      hospitalId: data['hospitalId'],
      date: data['date'] ?? '',
      timeSlot: data['timeSlot'] ?? '',
      examinationResult: data['examinationResult'] != null
          ? ExaminationResult.fromMap(Map<String, dynamic>.from(data['examinationResult']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'userId': userId,
      'bookingType': bookingType,
      'status': status,
      'patientProfile': patientProfile,
      'appointmentTime': appointmentTime,
      'createdAt': createdAt,
      'doctorId': doctorId,
      'clinicId': clinicId,
      'hospitalId': hospitalId,
      'date': date,
      'timeSlot': timeSlot,
    };

    if (doctorData != null) map['doctorData'] = doctorData!;
    if (clinicData != null) map['clinicData'] = clinicData!;
    if (hospitalData != null) map['hospitalData'] = hospitalData!;
    if (examinationResult != null) map['examinationResult'] = examinationResult!.toMap();

    return map;
  }
}

class ExaminationResult {
  final String symptoms;
  final String diagnosis;
  final String doctorNotes;
  final List<PrescriptionItem> prescription;
  final List<String> attachments;

  ExaminationResult({
    required this.symptoms,
    required this.diagnosis,
    required this.doctorNotes,
    required this.prescription,
    required this.attachments,
  });

  factory ExaminationResult.fromMap(Map<String, dynamic> data) {
    return ExaminationResult(
      symptoms: data['symptoms'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      doctorNotes: data['doctorNotes'] ?? '',
      prescription: (data['prescription'] as List<dynamic>? ?? [])
          .map((item) => PrescriptionItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      attachments: List<String>.from(data['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'doctorNotes': doctorNotes,
      'prescription': prescription.map((e) => e.toMap()).toList(),
      'attachments': attachments,
    };
  }
}

class PrescriptionItem {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory PrescriptionItem.fromMap(Map<String, dynamic> data) {
    return PrescriptionItem(
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}