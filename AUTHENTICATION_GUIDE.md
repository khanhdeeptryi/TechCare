# 🔐 Hệ thống Authentication với Role-Based Navigation

## ✅ Đã hoàn thành!

### 📦 Files đã tạo/cập nhật:

#### 1. **Models**
- ✅ `lib/models/user_model.dart` - Model User với role
- ✅ `lib/models/doctor.dart` - Model Doctor (đã cập nhật với thêm fields)

#### 2. **Services**
- ✅ `lib/services/auth_service.dart` - Service xử lý authentication

#### 3. **Authentication Screens**
- ✅ `lib/features/authenticate/signup_enhanced.dart` - Màn hình đăng ký mới
- ✅ `lib/features/authenticate/login.dart` - Đã cập nhật để dùng SignupEnhanced

#### 4. **Main Screens**
- ✅ `lib/features/doctor/doctor_main_screen.dart` - Main screen cho Doctor
- ✅ `lib/features/patient/patient_main_screen.dart` - Main screen cho Patient
- ✅ `lib/features/chat/chat_list_screen.dart` - Danh sách chat
- ✅ `lib/features/account/account_screen.dart` - Màn hình tài khoản

#### 5. **Navigation**
- ✅ `lib/wrapper_enhanced.dart` - Wrapper với role-based navigation

---

## 🎯 Tính năng đã implement

### 1. 📝 Màn hình Đăng ký (SignupEnhanced)

**Chức năng**:
- ✅ Lựa chọn role: **Bệnh nhân** hoặc **Bác sĩ**
- ✅ Form chung: Email, Password, Confirm Password, Họ tên
- ✅ Form bổ sung cho Bác sĩ:
  - Chuyên khoa (bắt buộc)
  - Bệnh viện làm việc (bắt buộc)
  - Số điện thoại (không bắt buộc)
  - Giới thiệu (không bắt buộc)
- ✅ Validation form
- ✅ UI đẹp với toggle role bằng card

### 2. 🔐 Logic Authentication (AuthService)

**Đăng ký Bệnh nhân**:
```dart
await authService.signUpPatient(
  email: email,
  password: password,
  displayName: name,
);
```

- ✅ Tạo user trong Firebase Auth
- ✅ Tạo document trong collection `users` với `role: 'patient'`

**Đăng ký Bác sĩ**:
```dart
await authService.signUpDoctor(
  email: email,
  password: password,
  name: name,
  specialty: specialty,
  hospital: hospital,
  phone: phone,
  bio: bio,
);
```

- ✅ Tạo user trong Firebase Auth
- ✅ Tạo document trong collection `users` với `role: 'doctor'`
- ✅ **QUAN TRỌNG**: Tạo document trong collection `doctors` (cùng UID)

### 3. 🧭 Role-Based Navigation

**Flow**:
```
User đăng nhập
    ↓
WrapperEnhanced kiểm tra authentication
    ↓
RoleNavigator đọc role từ Firestore
    ↓
├─ role == 'doctor' → DoctorMainScreen
└─ role == 'patient' → PatientMainScreen
```

**DoctorMainScreen** (4 tabs):
- Dashboard
- Lịch hẹn
- Tin nhắn
- Tài khoản

**PatientMainScreen** (3 tabs):
- Trang chủ
- Tin nhắn
- Tài khoản

---

## 📊 Cấu trúc Firestore

### Collection: `users`
```
users/{uid}
  ├── email: "user@example.com"
  ├── role: "patient" | "doctor"
  ├── createdAt: Timestamp
  ├── displayName: "Nguyễn Văn A"
  └── photoUrl: "url..." (optional)
```

### Collection: `doctors` (chỉ cho role doctor)
```
doctors/{uid}  // Dùng chung uid với users
  ├── name: "Dr. Nguyễn Văn A"
  ├── title: "Dr."
  ├── experience: 5
  ├── address: "Bệnh viện ABC"
  ├── imageUrl: ""
  ├── specialties: ["Tim mạch", "Nội khoa"]
  ├── bio: "Giới thiệu..."
  ├── hospital: "Bệnh viện ABC"
  ├── phone: "0123456789"
  ├── email: "doctor@example.com"
  ├── isVerified: false
  └── createdAt: Timestamp
```

---

## 🚀 Cách sử dụng

### 1. Cập nhật main.dart

Thay đổi từ `Wrapper()` sang `WrapperEnhanced()`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'wrapper_enhanced.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WrapperEnhanced(), // ← Thay đổi ở đây
    );
  }
}
```

### 2. Test đăng ký Bệnh nhân

1. Mở app → Login → Register
2. Chọn **"Bệnh nhân"**
3. Nhập: Họ tên, Email, Password
4. Nhấn Đăng ký
5. ✅ Sẽ vào PatientMainScreen

### 3. Test đăng ký Bác sĩ

1. Mở app → Login → Register
2. Chọn **"Bác sĩ"**
3. Nhập: Họ tên, Email, Password
4. Nhập thêm: Chuyên khoa, Bệnh viện
5. Nhấn Đăng ký
6. ✅ Sẽ vào DoctorMainScreen

### 4. Test Login

1. Đăng nhập với tài khoản đã tạo
2. ✅ Tự động điều hướng đúng role

---

## 🛠️ AuthService Methods

### Đăng ký
```dart
final authService = AuthService();

// Đăng ký Patient
await authService.signUpPatient(
  email: 'patient@example.com',
  password: 'password123',
  displayName: 'Nguyễn Văn A',
);

// Đăng ký Doctor
await authService.signUpDoctor(
  email: 'doctor@example.com',
  password: 'password123',
  name: 'Dr. Nguyễn Văn B',
  specialty: 'Tim mạch',
  hospital: 'Bệnh viện ABC',
  phone: '0123456789',
  bio: 'Bác sĩ chuyên khoa tim mạch',
);
```

### Đăng nhập
```dart
await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### Lấy thông tin user
```dart
final userData = await authService.getUserData(uid);
print('Role: ${userData?.role}');
print('Is Doctor: ${userData?.isDoctor}');
```

### Lấy thông tin doctor
```dart
final doctorData = await authService.getDoctorData(uid);
print('Specialty: ${doctorData?.specialties}');
print('Hospital: ${doctorData?.hospital}');
```

### Kiểm tra role
```dart
final role = await authService.getUserRole(uid);
if (role == 'doctor') {
  // Navigate to doctor screen
} else {
  // Navigate to patient screen
}
```

---

## 📱 UI Components

### SignupEnhanced Features

**Role Selection**:
- Card-based UI
- Icon và text rõ ràng
- Active state highlighting

**Form Validation**:
- Email format check
- Password length (min 6 chars)
- Required fields
- Password confirmation match

**Doctor-specific Section**:
- Highlighted trong orange box
- Chỉ hiện khi chọn role Doctor
- Fields: Specialty, Hospital, Phone, Bio

**Loading State**:
- Disable buttons khi đang xử lý
- Show CircularProgressIndicator

---

## 🔧 Customization

### Thêm fields cho Doctor

Trong `auth_service.dart`, method `signUpDoctor`:

```dart
final doctor = Doctor(
  // ... existing fields ...
  
  // Thêm field mới
  certification: certification,
  yearsOfExperience: yearsOfExperience,
  // ...
);
```

Trong `signup_enhanced.dart`, thêm TextField:

```dart
if (_selectedRole == 'doctor') ...[
  _buildTextField(
    controller: _certificationController,
    label: 'Chứng chỉ',
    icon: Icons.card_membership,
  ),
]
```

### Thêm role mới

1. Update `UserModel` trong `user_model.dart`
2. Thêm method `signUpXXX` trong `AuthService`
3. Update `RoleNavigator` trong `wrapper_enhanced.dart`
4. Tạo `XXXMainScreen`

---

## 🎨 UI Customization

### Thay đổi màu sắc

```dart
// Trong SignupEnhanced
Colors.blue[400] // Primary color
Colors.blue[50]  // Background color
Colors.orange    // Doctor section highlight
```

### Thay đổi icons

```dart
// Patient icon
Icons.person

// Doctor icon
Icons.medical_services
```

---

## ✅ Checklist Implementation

- ✅ Model UserModel với role
- ✅ Model Doctor với đầy đủ thông tin
- ✅ AuthService với signUpPatient/signUpDoctor
- ✅ Màn hình đăng ký với role selection
- ✅ Form validation
- ✅ Doctor-specific fields
- ✅ Tạo document trong users collection
- ✅ Tạo document trong doctors collection (cho doctor)
- ✅ WrapperEnhanced với role-based navigation
- ✅ RoleNavigator kiểm tra role
- ✅ DoctorMainScreen với 4 tabs
- ✅ PatientMainScreen với 3 tabs
- ✅ ChatListScreen
- ✅ AccountScreen
- ✅ Tích hợp với màn hình Login

---

## 🐛 Troubleshooting

### Lỗi: User role không tìm thấy

**Nguyên nhân**: Document trong Firestore chưa được tạo

**Giải pháp**: Kiểm tra Firebase Console → Firestore → Collection `users`

### Lỗi: Doctor data null

**Nguyên nhân**: Document trong collection `doctors` chưa có

**Giải pháp**: Đảm bảo `signUpDoctor` đã tạo cả 2 documents (users và doctors)

### Lỗi: Navigation không hoạt động

**Nguyên nhân**: Chưa update main.dart

**Giải pháp**: Thay `Wrapper()` thành `WrapperEnhanced()`

---

## 📝 Next Steps (Tùy chọn)

1. **Email Verification**: Xác thực email trước khi cho phép đăng nhập
2. **Admin Panel**: Xác thực bác sĩ (set `isVerified = true`)
3. **Profile Edit**: Cho phép edit thông tin cá nhân
4. **Upload Avatar**: Thêm ảnh đại diện
5. **Doctor Verification**: Upload chứng chỉ hành nghề
6. **Search**: Tìm kiếm bác sĩ theo chuyên khoa
7. **Rating**: Đánh giá bác sĩ
8. **Statistics**: Dashboard thống kê cho doctor

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra Firebase Console
2. Xem Flutter DevTools logs
3. Verify Firestore security rules
4. Check authentication state

---

**🎉 Hệ thống authentication với role-based navigation đã sẵn sàng!**

- ✅ Đăng ký với role Patient/Doctor
- ✅ Auto-navigation based on role
- ✅ Separate UI cho từng role
- ✅ Doctor-specific data management

**Happy Coding! 🚀**
