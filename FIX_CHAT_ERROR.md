# Hướng Dẫn Sửa Lỗi "Không Chat Được Với Agent"

## Mô Tả Lỗi

Khi gửi tin nhắn trong tab "Trợ lý y khoa", ứng dụng báo lỗi:

```
Lỗi: [firebase_functions/unknown] Unable to establish connection on channel: 
"dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call"
```

## Nguyên Nhân

Lỗi này xảy ra vì **Cloud Function chưa được deploy lên Firebase**. Ứng dụng Flutter đang cố gắng gọi function `guideAgent` nhưng function này chưa tồn tại trên Firebase.

## Giải Pháp

### Bước 1: Cài Đặt Firebase CLI (Nếu Chưa Có)

```bash
npm install -g firebase-tools
```

Sau đó đăng nhập:

```bash
firebase login
```

### Bước 2: Kiểm Tra Cấu Hình Firebase

Đảm bảo các file sau đã tồn tại trong thư mục gốc của project:

1. **firebase.json** - Cấu hình Firebase Functions
2. **.firebaserc** - Chứa project ID (techcare-1940d)

✅ Các file này đã được tạo sẵn trong project.

### Bước 3: Cài Đặt Dependencies

```bash
cd functions
npm install
```

### Bước 4: Cấu Hình Google AI API Key

**Quan trọng:** Bạn cần có API key từ Google AI Studio để sử dụng Gemini.

#### 4.1. Lấy API Key

1. Truy cập: https://makersuite.google.com/app/apikey
2. Đăng nhập bằng tài khoản Google
3. Click "Create API Key"
4. Chọn project hoặc tạo project mới
5. Copy API key

#### 4.2. Tạo File .env

Trong thư mục `functions/`, tạo file `.env`:

```bash
cd functions
```

Tạo file `.env` với nội dung:

```
GOOGLE_GENAI_API_KEY=AIza...your_actual_api_key_here
```

**Lưu ý:** Thay `AIza...your_actual_api_key_here` bằng API key thật của bạn.

**Trên Windows, bạn có thể tạo file bằng notepad:**

```powershell
notepad .env
```

Sau đó paste nội dung và lưu lại.

### Bước 5: Build TypeScript

```bash
# Trong thư mục functions
npm run build
```

Lệnh này sẽ compile TypeScript thành JavaScript. Nếu thành công, bạn sẽ thấy thư mục `lib/` được tạo ra.

### Bước 6: Deploy Cloud Functions

```bash
# Quay lại thư mục gốc
cd ..

# Deploy functions
firebase deploy --only functions
```

**Lưu ý:** Quá trình deploy có thể mất 3-5 phút.

Sau khi deploy thành công, bạn sẽ thấy:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/techcare-1940d/overview
Functions:
  guideAgent(us-central1): https://us-central1-techcare-1940d.cloudfunctions.net/guideAgent
  guideAgentHttp(us-central1): https://us-central1-techcare-1940d.cloudfunctions.net/guideAgentHttp
```

### Bước 7: Test Lại Ứng Dụng

1. Mở ứng dụng TechCare trên điện thoại/emulator
2. Đăng nhập bằng tài khoản user
3. Chọn tab "Trợ lý y khoa"
4. Gửi tin nhắn thử: "Làm thế nào để đặt lịch khám với bác sĩ?"
5. Đợi phản hồi từ AI (khoảng 2-5 giây)

## Xử Lý Lỗi Thường Gặp

### Lỗi 1: "Firebase CLI not found"

**Giải pháp:** Cài đặt Firebase CLI:

```bash
npm install -g firebase-tools
```

### Lỗi 2: "Permission denied" khi deploy

**Giải pháp:** Đăng nhập lại Firebase:

```bash
firebase logout
firebase login
```

### Lỗi 3: "GOOGLE_GENAI_API_KEY is not defined"

**Giải pháp:** 
- Kiểm tra file `.env` trong thư mục `functions/`
- Đảm bảo API key đúng format
- Không có khoảng trắng thừa

### Lỗi 4: Build TypeScript thất bại

**Giải pháp:**

```bash
cd functions
rm -rf node_modules
npm install
npm run build
```

### Lỗi 5: "Billing account not configured"

**Giải pháp:** 
- Firebase Functions yêu cầu Blaze Plan (pay-as-you-go)
- Truy cập: https://console.firebase.google.com/project/techcare-1940d/usage/details
- Upgrade lên Blaze Plan
- **Lưu ý:** Blaze Plan có free tier, bạn sẽ không bị tính phí nếu sử dụng trong giới hạn miễn phí

## Kiểm Tra Cloud Function Đã Deploy Chưa

### Cách 1: Qua Firebase Console

1. Truy cập: https://console.firebase.google.com/project/techcare-1940d/functions
2. Kiểm tra xem có function `guideAgent` và `guideAgentHttp` không

### Cách 2: Qua Firebase CLI

```bash
firebase functions:list
```

Bạn sẽ thấy danh sách functions đã deploy.

### Cách 3: Test HTTP Endpoint

```bash
curl -X POST https://us-central1-techcare-1940d.cloudfunctions.net/guideAgentHttp \
  -H "Content-Type: application/json" \
  -d '{"userQuestion": "Xin chào"}'
```

Nếu function hoạt động, bạn sẽ nhận được response JSON.

## Tóm Tắt Các Bước

1. ✅ Cài đặt Firebase CLI
2. ✅ Đăng nhập Firebase
3. ✅ Cài đặt dependencies: `cd functions && npm install`
4. ✅ Tạo file `.env` với GOOGLE_GENAI_API_KEY
5. ✅ Build TypeScript: `npm run build`
6. ✅ Deploy: `firebase deploy --only functions`
7. ✅ Test lại ứng dụng

## Liên Hệ Hỗ Trợ

Nếu vẫn gặp lỗi sau khi làm theo hướng dẫn, vui lòng:
- Kiểm tra logs: `firebase functions:log`
- Kiểm tra Firebase Console: https://console.firebase.google.com/project/techcare-1940d/functions

## Tài Liệu Tham Khảo

- Firebase Functions: https://firebase.google.com/docs/functions
- Google AI Studio: https://makersuite.google.com/
- Genkit Documentation: https://firebase.google.com/docs/genkit
