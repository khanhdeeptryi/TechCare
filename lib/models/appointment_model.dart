// File: lib/models/appointment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  /// ID document Firestore
  final String id;

  /// ID user đã đặt lịch
  final String userId;

  /// Phân loại lịch hẹn: "doctor", "clinic", "hospital", ...
  final String bookingType;

  /// Trạng thái: "pending", "confirmed", "completed", "cancelled"
  final String status;

  /// Bản sao hồ sơ bệnh nhân tại thời điểm đặt lịch
  final Map<String, dynamic> patientProfile;

  /// Bản sao thông tin bác sĩ (tên, chuyên khoa, v.v.)
  final Map<String, dynamic> doctorInfo;

  /// Thời điểm diễn ra cuộc hẹn
  final Timestamp appointmentTime;

  /// Thời điểm tạo lịch hẹn
  final Timestamp createdAt;

  /// ID bác sĩ (nếu bookingType == "doctor")
  final String? doctorId;

  /// ID phòng khám
  final String? clinicId;

  /// ID bệnh viện
  final String? hospitalId;

  /// Ngày khám (dùng để lọc slot theo ngày, dạng "yyyy-MM-dd")
  final String date; // ví dụ "2025-11-20"

  /// Khung giờ (ví dụ "17:30-17:40")
  final String timeSlot;

  /// Kết quả khám (sau khi bác sĩ cập nhật)
  final ExaminationResult? examinationResult;

  Appointment({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.status,
    required this.patientProfile,
    required this.doctorInfo,
    required this.appointmentTime,
    required this.createdAt,
    required this.date,
    required this.timeSlot,
    this.doctorId,
    this.clinicId,
    this.hospitalId,
    this.examinationResult,
  });

  /// Tạo từ Firestore (data Map + documentId)
  factory Appointment.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Appointment(
      id: documentId,
      userId: data['userId'] ?? '',
      bookingType: data['bookingType'] ?? '',
      status: data['status'] ?? '',
      patientProfile: Map<String, dynamic>.from(
        data['patientProfile'] ?? <String, dynamic>{},
      ),
      doctorInfo: Map<String, dynamic>.from(
        data['doctorInfo'] ?? <String, dynamic>{},
      ),
      appointmentTime: data['appointmentTime'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      doctorId: data['doctorId'],
      clinicId: data['clinicId'],
      hospitalId: data['hospitalId'],
      date: data['date'] ?? '',
      timeSlot: data['timeSlot'] ?? '',
      examinationResult: data['examinationResult'] != null
          ? ExaminationResult.fromMap(
              Map<String, dynamic>.from(data['examinationResult']),
            )
          : null,
    );
  }

  /// Convert ra Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookingType': bookingType,
      'status': status,
      'patientProfile': patientProfile,
      'doctorInfo': doctorInfo,
      'appointmentTime': appointmentTime,
      'createdAt': createdAt,
      'doctorId': doctorId,
      'clinicId': clinicId,
      'hospitalId': hospitalId,
      'date': date,
      'timeSlot': timeSlot,
      if (examinationResult != null)
        'examinationResult': examinationResult!.toMap(),
    };
  }

  /// Factory tiện cho case đặt lịch bác sĩ
  factory Appointment.forDoctorBooking({
    required String id,
    required String userId,
    required Map<String, dynamic> patientProfile,
    required Map<String, dynamic> doctorInfo,
    required String doctorId,
    required String date,
    required String timeSlot,
  }) {
    final now = Timestamp.now();

    return Appointment(
      id: id,
      userId: userId,
      bookingType: 'doctor',
      status: 'pending', // mới tạo
      patientProfile: patientProfile,
      doctorInfo: doctorInfo,
      date: date,
      timeSlot: timeSlot,
      doctorId: doctorId,
      clinicId: null,
      hospitalId: null,
      appointmentTime: now, // nếu muốn chuẩn hơn, convert từ date + timeSlot
      createdAt: now,
      examinationResult: null,
    );
  }
}

// ================== ExaminationResult ==================

class ExaminationResult {
  /// Triệu chứng
  final String symptoms;

  /// Chẩn đoán
  final String diagnosis;

  /// Dặn dò của bác sĩ
  final String doctorNotes;

  /// Đơn thuốc
  final List<PrescriptionItem> prescription;

  /// Link file X-quang, xét nghiệm, v.v. (Firebase Storage URLs)
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
          .map((item) =>
              PrescriptionItem.fromMap(Map<String, dynamic>.from(item)))
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

// ================== PrescriptionItem ==================

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
