# Hướng Dẫn Setup Firebase Cho Trợ Lý Y Khoa

## Tổng Quan

Tài liệu này hướng dẫn chi tiết cách setup Firebase và deploy Cloud Functions cho tính năng Trợ Lý Y Khoa trong ứng dụng TechCare.

## Thông Tin Project

- **Project ID**: `techcare-1940d`
- **Region**: `us-central1`
- **Runtime**: Node.js 18

---

## Phần 1: Kiểm Tra Cấu Hình Firebase

### 1.1. Kiểm Tra Firebase CLI

Mở terminal và chạy:

```bash
firebase --version
```

Nếu chưa cài đặt, chạy:

```bash
npm install -g firebase-tools
```

### 1.2. Đăng Nhập Firebase

```bash
firebase login
```

Trình duyệt sẽ mở để bạn đăng nhập bằng tài khoản Google có quyền truy cập project `techcare-1940d`.

### 1.3. Kiểm Tra Project Hiện Tại

```bash
firebase projects:list
```

Xác nhận rằng project `techcare-1940d` có trong danh sách.

```bash
firebase use
```

Kết quả phải hiển thị: `Active Project: techcare-1940d (techcare-1940d)`

---

## Phần 2: Cấu Hình Google AI API Key

### 2.1. Lấy API Key

1. Truy cập: https://makersuite.google.com/app/apikey
2. Đăng nhập bằng tài khoản Google
3. Click **"Create API Key"** hoặc sử dụng key có sẵn
4. Copy API key (dạng: `AIza...`)

### 2.2. Cấu Hình API Key Cho Cloud Functions

**Cách 1: Sử dụng Firebase Environment Config (Khuyến nghị)**

```bash
firebase functions:config:set googleai.api_key="YOUR_API_KEY_HERE"
```

Thay `YOUR_API_KEY_HERE` bằng API key thật của bạn.

Kiểm tra cấu hình:

```bash
firebase functions:config:get
```

**Cách 2: Sử dụng File .env (Chỉ cho local testing)**

Tạo file `functions/.env`:

```bash
cd functions
echo GOOGLE_GENAI_API_KEY=YOUR_API_KEY_HERE > .env
```

⚠️ **Lưu ý**: File `.env` chỉ hoạt động khi test local, không được deploy lên Firebase.

---

## Phần 3: Cài Đặt Dependencies

### 3.1. Cài Đặt Node Modules

```bash
cd functions
npm install
```

Kết quả: Cài đặt 766 packages bao gồm:
- `@genkit-ai/core`
- `@genkit-ai/googleai`
- `firebase-functions`
- `firebase-admin`

### 3.2. Build TypeScript

```bash
npm run build
```

Lệnh này compile TypeScript thành JavaScript trong thư mục `lib/`.

---

## Phần 4: Deploy Cloud Functions Lên Firebase

### 4.1. Deploy Functions

Quay lại thư mục gốc của project:

```bash
cd ..
firebase deploy --only functions
```

### 4.2. Theo Dõi Quá Trình Deploy

Bạn sẽ thấy output như sau:

```
=== Deploying to 'techcare-1940d'...

i  deploying functions
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
✔  functions: required API cloudbuild.googleapis.com is enabled
i  functions: preparing functions directory for uploading...
i  functions: packaged functions (XX.XX KB) for uploading
✔  functions: functions folder uploaded successfully
i  functions: creating Node.js 18 function guideAgent(us-central1)...
i  functions: creating Node.js 18 function guideAgentHttp(us-central1)...
✔  functions[guideAgent(us-central1)]: Successful create operation.
✔  functions[guideAgentHttp(us-central1)]: Successful create operation.

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/techcare-1940d/overview
```

### 4.3. Xác Nhận Deploy Thành Công

Kiểm tra danh sách functions:

```bash
firebase functions:list
```

Kết quả phải hiển thị:

```
┌───────────────────┬────────────┬─────────┐
│ Function Name     │ Region     │ Runtime │
├───────────────────┼────────────┼─────────┤
│ guideAgent        │ us-central1│ nodejs18│
│ guideAgentHttp    │ us-central1│ nodejs18│
└───────────────────┴────────────┴─────────┘
```

---

## Phần 5: Kiểm Tra Trên Firebase Console

### 5.1. Truy Cập Firebase Console

1. Mở trình duyệt và truy cập: https://console.firebase.google.com/
2. Chọn project **techcare-1940d**

### 5.2. Kiểm Tra Cloud Functions

1. Trong menu bên trái, click **"Functions"**
2. Bạn sẽ thấy 2 functions:
   - `guideAgent` (Callable function - dùng cho Flutter app)
   - `guideAgentHttp` (HTTP function - dùng cho testing)

### 5.3. Xem Chi Tiết Function

Click vào `guideAgent` để xem:
- **Region**: us-central1
- **Runtime**: Node.js 18
- **Memory**: 256 MB (mặc định)
- **Timeout**: 60s (mặc định)
- **Trigger**: HTTPS Callable

### 5.4. Kiểm Tra Logs

1. Click tab **"Logs"** trong function detail
2. Bạn sẽ thấy logs của function khi có request

---

## Phần 6: Test Cloud Function

### 6.1. Test Từ Terminal

```bash
firebase functions:shell
```

Trong shell, gọi function:

```javascript
guideAgent({userQuestion: "Làm thế nào để đặt lịch khám bác sĩ?"})
```

### 6.2. Test Từ Flutter App

1. Mở ứng dụng TechCare
2. Đăng nhập bằng tài khoản user
3. Chọn tab **"Trợ lý y khoa"**
4. Gửi tin nhắn: "Làm thế nào để đặt lịch khám bác sĩ?"
5. Đợi phản hồi từ AI

### 6.3. Test HTTP Endpoint (Optional)

Lấy URL của function:

```bash
firebase functions:config:get
```

Hoặc xem trong Firebase Console.

Gửi POST request:

```bash
curl -X POST https://us-central1-techcare-1940d.cloudfunctions.net/guideAgentHttp \
  -H "Content-Type: application/json" \
  -d '{"userQuestion": "Làm thế nào để đặt lịch khám bác sĩ?"}'
```

---

## Phần 7: Xử Lý Lỗi Thường Gặp

### Lỗi 1: "Unable to establish connection"

**Nguyên nhân**: Cloud Function chưa được deploy hoặc region không đúng.

**Giải pháp**:
1. Kiểm tra function đã deploy: `firebase functions:list`
2. Xác nhận region trong code Flutter là `us-central1`
3. Deploy lại: `firebase deploy --only functions`

### Lỗi 2: "PERMISSION_DENIED"

**Nguyên nhân**: Chưa cấu hình Firebase Authentication hoặc Security Rules.

**Giải pháp**:
1. Đảm bảo user đã đăng nhập trong app
2. Kiểm tra Firebase Authentication trong Console
3. Cấu hình Security Rules nếu cần

### Lỗi 3: "INTERNAL: An error occurred"

**Nguyên nhân**: Lỗi trong code hoặc thiếu API key.

**Giải pháp**:
1. Kiểm tra logs: `firebase functions:log`
2. Xác nhận API key đã được cấu hình: `firebase functions:config:get`
3. Kiểm tra code trong `functions/src/guideAgent.ts`

### Lỗi 4: "Function not found"

**Nguyên nhân**: Tên function không đúng hoặc chưa deploy.

**Giải pháp**:
1. Xác nhận tên function trong code Flutter là `guideAgent`
2. Deploy lại: `firebase deploy --only functions`

---

## Phần 8: Cập Nhật Function

### 8.1. Sửa Code

Chỉnh sửa file `functions/src/guideAgent.ts` hoặc `functions/src/index.ts`.

### 8.2. Build Lại

```bash
cd functions
npm run build
```

### 8.3. Deploy Lại

```bash
cd ..
firebase deploy --only functions
```

### 8.4. Xem Logs

```bash
firebase functions:log --only guideAgent
```

---

## Phần 9: Monitoring và Optimization

### 9.1. Xem Usage

Trong Firebase Console > Functions > Dashboard:
- Số lượng invocations
- Execution time
- Memory usage
- Error rate

### 9.2. Tối Ưu Performance

Nếu function chạy chậm, có thể tăng memory:

Thêm vào `functions/src/index.ts`:

```typescript
export const guideAgent = functions
  .runWith({
    memory: '512MB',
    timeoutSeconds: 120,
  })
  .https.onCall(async (data, context) => {
    // ... existing code
  });
```

Deploy lại sau khi thay đổi.

### 9.3. Cost Management

- Free tier: 2 triệu invocations/tháng
- Theo dõi usage trong Firebase Console > Usage and billing

---

## Phần 10: Checklist Hoàn Thành

Đánh dấu các bước đã hoàn thành:

- [ ] Cài đặt Firebase CLI
- [ ] Đăng nhập Firebase
- [ ] Xác nhận project `techcare-1940d`
- [ ] Lấy Google AI API Key
- [ ] Cấu hình API key: `firebase functions:config:set googleai.api_key="..."`
- [ ] Cài đặt dependencies: `cd functions && npm install`
- [ ] Build TypeScript: `npm run build`
- [ ] Deploy functions: `firebase deploy --only functions`
- [ ] Kiểm tra trên Firebase Console
- [ ] Test từ Flutter app
- [ ] Xem logs để đảm bảo không có lỗi

---

## Tài Liệu Tham Khảo

- Firebase Functions Documentation: https://firebase.google.com/docs/functions
- Firebase CLI Reference: https://firebase.google.com/docs/cli
- Google AI Studio: https://makersuite.google.com/
- Genkit Documentation: https://firebase.google.com/docs/genkit

---

## Liên Hệ Hỗ Trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs: `firebase functions:log`
2. Xem lại các bước trong tài liệu này
3. Tham khảo tài liệu Firebase chính thức

---

**Cập nhật lần cuối**: 2026-01-09
**Phiên bản**: 1.0
