# Hướng Dẫn Sử Dụng Trợ Lý Y Khoa TechCare

## Giới Thiệu

Trợ lý Y khoa là một tính năng AI được tích hợp vào ứng dụng TechCare, giúp người dùng:
- Hướng dẫn cách đặt lịch khám với bác sĩ, phòng khám, bệnh viện
- Hướng dẫn cách cập nhật hồ sơ sức khỏe
- Hướng dẫn cách chat và gọi video với bác sĩ
- Hướng dẫn cách đặt lịch tiêm chủng và xét nghiệm
- Trả lời các câu hỏi về cách sử dụng ứng dụng TechCare

## Cách Sử Dụng Trợ Lý Y Khoa

### Bước 1: Đăng Nhập Vào Ứng Dụng
1. Mở ứng dụng TechCare
2. Đăng nhập bằng tài khoản **user** (không phải doctor, clinic, hoặc hospital)
3. Bạn sẽ thấy màn hình chính với 5 tab ở thanh điều hướng dưới cùng

### Bước 2: Truy Cập Tab "Trợ Lý Y Khoa"
1. Nhìn vào thanh điều hướng (navbar) ở dưới cùng màn hình
2. Chọn tab thứ 3 có tên **"Trợ lý y khoa"** (biểu tượng medical_services)
3. Màn hình chat với trợ lý AI sẽ hiển thị

### Bước 3: Chat Với Trợ Lý
1. Bạn sẽ thấy tin nhắn chào mừng từ trợ lý
2. Nhập câu hỏi của bạn vào ô text ở dưới cùng
3. Nhấn nút gửi (biểu tượng mũi tên) hoặc Enter
4. Đợi trợ lý phản hồi (sẽ có indicator "Đang suy nghĩ...")
5. Đọc câu trả lời từ trợ lý

### Ví Dụ Câu Hỏi Bạn Có Thể Hỏi:
- "Làm thế nào để đặt lịch khám với bác sĩ?"
- "Tôi muốn cập nhật hồ sơ sức khỏe, làm sao?"
- "Cách chat với bác sĩ như thế nào?"
- "Làm sao để đặt lịch tiêm chủng?"
- "Tôi muốn xem lịch hẹn của mình"
- "Cách hủy lịch hẹn?"

## Lưu Ý Quan Trọng

### Trước Khi Sử Dụng
⚠️ **Bạn cần deploy Cloud Function trước khi tính năng này hoạt động!**

Nếu bạn chưa deploy Cloud Function, trợ lý sẽ báo lỗi khi bạn gửi tin nhắn.

### Yêu Cầu Hệ Thống
- ✅ Đã cài đặt Firebase CLI
- ✅ Đã cấu hình Firebase project
- ✅ Đã có Google Cloud API Key cho Gemini
- ✅ Đã chạy `flutter pub get` để cài đặt dependencies mới

---

## Hướng Dẫn Deploy Cloud Function

### Bước 1: Cài Đặt Dependencies

Mở terminal và chạy các lệnh sau:

```bash
# Di chuyển vào thư mục functions
cd functions

# Cài đặt Node.js dependencies
npm install
```

### Bước 2: Cấu Hình Google AI API Key

Bạn cần có API key từ Google AI Studio để sử dụng Gemini:

1. Truy cập: https://makersuite.google.com/app/apikey
2. Tạo API key mới (hoặc sử dụng API key có sẵn)
3. Tạo file `.env` trong thư mục `functions/`:

```bash
# Trong thư mục functions, tạo file .env
cd functions
echo "GOOGLE_GENAI_API_KEY=your_actual_api_key_here" > .env
```

**Lưu ý:** Thay `your_actual_api_key_here` bằng API key thật của bạn.

**Quan trọng:** File `.env` chứa thông tin nhạy cảm, đừng commit lên Git!

### Bước 3: Build TypeScript

```bash
# Trong thư mục functions
npm run build
```

Lệnh này sẽ compile TypeScript thành JavaScript trong thư mục `lib/`.

### Bước 4: Deploy Cloud Functions

```bash
# Quay lại thư mục gốc của project
cd ..

# Deploy functions lên Firebase
firebase deploy --only functions
```

Quá trình deploy có thể mất vài phút. Sau khi hoàn tất, bạn sẽ thấy:
```
✔  Deploy complete!

Functions:
  guideAgent(us-central1)
  guideAgentHttp(us-central1)
```

### Bước 5: Test Cloud Function (Tùy Chọn)

Bạn có thể test function bằng Firebase Emulator:

```bash
cd functions
npm run serve
```

Hoặc test trực tiếp trên Firebase Console:
1. Vào Firebase Console → Functions
2. Chọn function `guideAgent`
3. Nhấn "Test function"
4. Gửi payload:
```json
{
  "userQuestion": "Làm thế nào để đặt lịch khám bác sĩ?"
}
```

---

## Cập Nhật Dependencies Flutter

Sau khi thêm `cloud_functions` và `http` vào `pubspec.yaml`, chạy:

```bash
flutter pub get
```

Nếu gặp lỗi, thử:
```bash
flutter clean
flutter pub get
```

---

## Xử Lý Lỗi Thường Gặp

### Lỗi 1: "Cloud Function not found"
**Nguyên nhân:** Chưa deploy Cloud Function hoặc tên function không đúng.

**Giải pháp:**
1. Kiểm tra đã deploy chưa: `firebase functions:list`
2. Đảm bảo function tên là `guideAgent`
3. Deploy lại nếu cần: `firebase deploy --only functions`

### Lỗi 2: "Permission denied"
**Nguyên nhân:** Firebase Security Rules chặn request.

**Giải pháp:**
1. Vào Firebase Console → Functions
2. Kiểm tra permissions của function
3. Đảm bảo function cho phép authenticated users

### Lỗi 3: "API key not valid"
**Nguyên nhân:** Google AI API key không hợp lệ hoặc chưa được set.

**Giải pháp:**
1. Kiểm tra API key: `firebase functions:config:get`
2. Set lại API key: `firebase functions:config:set googleai.key="YOUR_KEY"`
3. Deploy lại functions

### Lỗi 4: "Module 'genkit' not found"
**Nguyên nhân:** Chưa cài đặt dependencies trong thư mục functions.

**Giải pháp:**
```bash
cd functions
npm install
npm run build
```

### Lỗi 5: Trợ lý không phản hồi bằng tiếng Việt
**Nguyên nhân:** System prompt đã được thiết kế để phản hồi bằng tiếng Việt, nhưng có thể cần điều chỉnh.

**Giải pháp:** Trợ lý sẽ tự động phản hồi bằng tiếng Việt vì:
- App context được viết bằng tiếng Việt
- User hỏi bằng tiếng Việt
- Gemini tự động detect và match ngôn ngữ

---

## Kiểm Tra Logs

Để xem logs của Cloud Function:

```bash
firebase functions:log
```

Hoặc xem real-time logs:
```bash
firebase functions:log --only guideAgent
```

---

## Cấu Trúc File

```
tech_care/
├── lib/
│   ├── features/
│   │   └── medical_assistant/
│   │       └── medical_assistant_page.dart  # UI chat với trợ lý
│   └── homepage.dart                         # Tích hợp tab trợ lý
├── functions/
│   ├── src/
│   │   ├── index.ts                          # Export Cloud Functions
│   │   └── guideAgent.ts                     # Genkit AI flow
│   ├── package.json                          # Node dependencies
│   └── tsconfig.json                         # TypeScript config
└── pubspec.yaml                              # Flutter dependencies
```

---

## Tính Năng Nâng Cao (Tùy Chọn)

### Lưu Lịch Sử Chat
Hiện tại, lịch sử chat chỉ lưu trong memory (mất khi thoát app). Để lưu vào Firestore:

1. Tạo collection `chat_history` trong Firestore
2. Lưu mỗi tin nhắn với userId, timestamp, message, response
3. Load lại khi user mở app

### Thêm Typing Indicator
Để UX tốt hơn, có thể thêm animation "đang gõ..." khi AI đang suy nghĩ.

### Rate Limiting
Để tránh spam, có thể giới hạn số lượng request mỗi user mỗi phút.

---

## Hỗ Trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs: `firebase functions:log`
2. Kiểm tra Firebase Console → Functions
3. Đảm bảo đã follow đúng các bước trên
4. Kiểm tra API key còn hạn sử dụng

---

## Tóm Tắt Nhanh

### Cho Người Dùng Cuối:
1. Đăng nhập vào app bằng tài khoản user
2. Chọn tab "Trợ lý y khoa" ở thanh navbar dưới cùng
3. Nhập câu hỏi và nhận câu trả lời từ AI

### Cho Developer:
1. `cd functions && npm install`
2. `firebase functions:config:set googleai.key="YOUR_KEY"`
3. `npm run build`
4. `firebase deploy --only functions`
5. `flutter pub get`
6. Test app!

---

**Chúc bạn sử dụng Trợ Lý Y Khoa TechCare thành công! 🎉**
