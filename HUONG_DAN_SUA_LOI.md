# Hướng Dẫn Sửa Lỗi "Unable to establish connection"

## Mô Tả Lỗi

Khi bạn gửi tin nhắn cho Trợ lý Y khoa, bạn gặp lỗi:

```
Lỗi: [firebase_functions/unknown] Unable to establish connection on channel: 
'dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call'
```

## Nguyên Nhân

Lỗi này xảy ra do **2 vấn đề chính**:

### 1. Cloud Function Chưa Được Deploy
- Cloud Function `guideAgent` chưa được deploy lên Firebase
- Ứng dụng Flutter không thể kết nối đến function vì nó không tồn tại trên server

### 2. Region Không Được Chỉ Định
- Code Flutter gọi Cloud Function mà không chỉ định region cụ thể
- Điều này có thể gây lỗi kết nối

## Giải Pháp

### ✅ Đã Sửa Trong Code

#### 1. Cập Nhật Flutter Code (medical_assistant_page.dart)
Đã thay đổi từ:
```dart
final functions = FirebaseFunctions.instance;
```

Thành:
```dart
final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
```

#### 2. Cập Nhật System Instruction (guideAgent.ts)
Đã thêm yêu cầu rõ ràng để agent **trả lời bằng tiếng Việt**:
```typescript
QUAN TRỌNG: BẠN PHẢI TRẢ LỜI BẰNG TIẾNG VIỆT! 
Tất cả câu trả lời của bạn phải được viết hoàn toàn bằng tiếng Việt, không được dùng tiếng Anh.
```

### 🚀 Các Bước Deploy Cloud Function

#### Bước 1: Kiểm Tra Cấu Hình Firebase

Đảm bảo bạn đã có file `firebase.json` và `.firebaserc` trong thư mục gốc của project.

**Nếu chưa có, tạo file `firebase.json`:**
```json
{
  "functions": {
    "source": "functions",
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run build"
    ],
    "runtime": "nodejs18"
  }
}
```

**Nếu chưa có, tạo file `.firebaserc`:**
```json
{
  "projects": {
    "default": "techcare-1940d"
  }
}
```

#### Bước 2: Cài Đặt Firebase CLI

Nếu chưa cài đặt Firebase CLI:
```bash
npm install -g firebase-tools
```

Đăng nhập Firebase:
```bash
firebase login
```

#### Bước 3: Cấu Hình Google AI API Key

**QUAN TRỌNG:** Bạn cần API key từ Google AI Studio để sử dụng Gemini.

1. Truy cập: https://makersuite.google.com/app/apikey
2. Tạo API key mới (hoặc sử dụng key có sẵn)
3. Lưu API key vào Firebase Config:

```bash
firebase functions:config:set google.genai_api_key="YOUR_API_KEY_HERE"
```

**Thay `YOUR_API_KEY_HERE` bằng API key thật của bạn.**

#### Bước 4: Deploy Cloud Functions

```bash
# Từ thư mục gốc của project
firebase deploy --only functions
```

Quá trình deploy sẽ mất vài phút. Sau khi hoàn tất, bạn sẽ thấy:
```
✔  Deploy complete!

Functions:
  guideAgent(us-central1)
  guideAgentHttp(us-central1)
```

#### Bước 5: Test Trên Ứng Dụng

1. Mở ứng dụng TechCare
2. Đăng nhập bằng tài khoản user
3. Chọn tab "Trợ lý y khoa" (tab thứ 3)
4. Gửi tin nhắn thử: "Làm thế nào để đặt lịch khám bác sĩ?"
5. Agent sẽ trả lời bằng tiếng Việt

## Kiểm Tra Logs

Nếu vẫn gặp lỗi, kiểm tra logs của Cloud Function:

```bash
firebase functions:log
```

Hoặc xem logs trên Firebase Console:
https://console.firebase.google.com/project/techcare-1940d/functions/logs

## Các Lỗi Thường Gặp

### Lỗi: "Function not found"
**Nguyên nhân:** Cloud Function chưa được deploy hoặc tên function không đúng.
**Giải pháp:** Chạy lại `firebase deploy --only functions`

### Lỗi: "Permission denied"
**Nguyên nhân:** Chưa đăng nhập Firebase CLI hoặc không có quyền deploy.
**Giải pháp:** Chạy `firebase login` và đảm bảo tài khoản có quyền deploy

### Lỗi: "API key not configured"
**Nguyên nhân:** Chưa cấu hình Google AI API key.
**Giải pháp:** Chạy `firebase functions:config:set google.genai_api_key="YOUR_KEY"`

### Lỗi: "Region mismatch"
**Nguyên nhân:** Region trong Flutter code không khớp với region deploy.
**Giải pháp:** Đảm bảo cả hai đều dùng `us-central1`

## Xác Nhận Deploy Thành Công

Sau khi deploy, bạn có thể kiểm tra function đã được deploy chưa:

```bash
firebase functions:list
```

Bạn sẽ thấy:
```
┌─────────────────┬────────────┬─────────────┐
│ Function        │ Region     │ Runtime     │
├─────────────────┼────────────┼─────────────┤
│ guideAgent      │ us-central1│ nodejs18    │
│ guideAgentHttp  │ us-central1│ nodejs18    │
└─────────────────┴────────────┴─────────────┘
```

## Tóm Tắt Các Thay Đổi

### Files Đã Sửa:
1. ✅ `lib/features/medical_assistant/medical_assistant_page.dart`
   - Thêm region 'us-central1' khi gọi Cloud Function

2. ✅ `functions/src/guideAgent.ts`
   - Thêm yêu cầu trả lời bằng tiếng Việt vào SYSTEM_INSTRUCTION
   - Cập nhật RESPONSE GUIDELINES bằng tiếng Việt

3. ✅ `functions/lib/` (auto-generated)
   - Code TypeScript đã được compile thành JavaScript

### Bước Tiếp Theo:
1. ⚠️ **BẠN CẦN DEPLOY** Cloud Function lên Firebase
2. ⚠️ **BẠN CẦN CẤU HÌNH** Google AI API key
3. ✅ Sau đó test lại trên ứng dụng

## Hỗ Trợ

Nếu vẫn gặp vấn đề, vui lòng:
1. Kiểm tra logs: `firebase functions:log`
2. Kiểm tra Firebase Console: https://console.firebase.google.com
3. Đảm bảo đã cấu hình đúng API key
4. Đảm bảo project ID đúng: `techcare-1940d`

---

**Lưu ý:** Sau khi deploy thành công, agent sẽ tự động trả lời bằng tiếng Việt cho tất cả câu hỏi của người dùng.
