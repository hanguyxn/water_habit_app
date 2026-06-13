# Hướng dẫn Cài đặt & Triển khai 🚀

Tài liệu này hướng dẫn chi tiết cách thiết lập môi trường phát triển, cấu hình dịch vụ Firebase và đóng gói phát hành ứng dụng **Water Habit App**.

---

## 📋 Yêu cầu hệ thống (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt:

1. **Flutter SDK**: Phiên bản `^3.12.2` hoặc mới hơn.
2. **Dart SDK**: Đi kèm cùng phiên bản Flutter tương ứng.
3. **Android Studio & Android SDK**: (Nếu lập trình cho Android) cài đặt thêm JDK 11 hoặc 17.
4. **Xcode**: (Nếu lập trình cho iOS/macOS - yêu cầu máy tính chạy hệ điều hành macOS).
5. **CocoaPods**: Công cụ quản lý thư viện cho iOS (`pod --version`).
6. **Node.js & npm**: Cần thiết để cài đặt Firebase CLI.

---

## 🛠️ Các bước thiết lập ban đầu (Initial Setup)

### Bước 1: Tải các thư viện phụ thuộc (Dependencies)
Mở terminal tại thư mục gốc của dự án (`e:\Work\app`) và chạy lệnh:
```bash
flutter pub get
```

### Bước 2: Chạy bộ sinh mã tự động (Build Runner)
Dự án sử dụng `freezed` và `json_serializable` để sinh mã tự động cho các Model (ví dụ: `user_model`, `profile_model`). Hãy chạy lệnh sau để sinh ra các file `.freezed.dart` và `.g.dart` tương ứng:
```bash
dart run build_runner build --delete-conflicting-outputs
```
> **Mẹo**: Nếu bạn muốn tự động tạo lại các file này mỗi khi mã nguồn thay đổi, hãy chạy lệnh:
> `dart run build_runner watch --delete-conflicting-outputs`

---

## 🔥 Thiết lập liên kết Firebase (Firebase Configuration)

Ứng dụng sử dụng Firebase để quản lý xác thực, cơ sở dữ liệu Firestore, lưu trữ ảnh Storage và đẩy thông báo Cloud Messaging.

### Bước 1: Cài đặt Firebase CLI & FlutterFire CLI
Chạy lệnh sau trên CMD/Terminal để cài đặt CLI toàn cục:
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### Bước 2: Đăng nhập Firebase
```bash
firebase login
```

### Bước 3: Cấu hình liên kết dự án (FlutterFire Configure)
Chạy lệnh sau tại thư mục gốc của dự án:
```bash
flutterfire configure
```
1. Chọn dự án Firebase hiện có của bạn (hoặc chọn tạo dự án mới).
2. Chọn các nền tảng muốn liên kết (Android, iOS).
3. Lệnh này sẽ tự động tạo file `lib/firebase_options.dart` và đăng ký ứng dụng của bạn trên Firebase Console, đồng thời tải xuống các file cấu hình `google-services.json` (Android) và `GoogleService-Info.plist` (iOS).

### Bước 4: Kích hoạt Firebase trong code
Sau khi có file `firebase_options.dart`, hãy mở file [main.dart](file:///e:/Work/app/lib/main.dart) và bỏ dấu chú thích (uncomment) phần khởi tạo Firebase:

```dart
// Bỏ dấu chú thích ở đầu file main.dart:
import 'package:firebase_core/firebase_core.dart';
import 'package:water_habit_app/firebase_options.dart';

// Bên trong hàm main():
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bỏ chú thích dòng dưới đây:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ...
}
```

### Bước 5: Cấu hình dịch vụ trên Firebase Console
Truy cập vào [Firebase Console](https://console.firebase.google.com/):
1. **Authentication**: Bật phương thức đăng nhập `Email/Password`, `Google`, và `Apple` nếu cần.
2. **Cloud Firestore**: Khởi tạo database Firestore ở chế độ kiểm thử (Test Mode) hoặc cấu hình Rules cơ bản:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
3. **Firebase Storage**: Khởi tạo Storage Bucket để lưu trữ ảnh đại diện người dùng. Cấu hình Rules cho phép đọc ghi ảnh đại diện:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /avatars/{userId}/{allPaths=**} {
         allow read;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

---

## 📲 Chạy ứng dụng trên thiết bị (Running App)

Để chạy thử ứng dụng trên Simulator (iOS) hoặc Emulator/Thiết bị vật lý (Android):

1. Kiểm tra danh sách thiết bị đang kết nối:
   ```bash
   flutter devices
   ```
2. Khởi chạy ứng dụng:
   ```bash
   flutter run
   ```

---

## 📦 Đóng gói ứng dụng phát hành (Building Release)

### 🤖 Đóng gói ứng dụng cho hệ máy Android
1. Để tạo gói cài đặt trực tiếp APK:
   ```bash
   flutter build apk --release
   ```
2. Để đóng gói định dạng App Bundle (dành cho tải lên Google Play Console):
   ```bash
   flutter build appbundle --release
   ```
   *File đầu ra sẽ nằm tại thư mục `build/app/outputs/bundle/release/app-release.aab`.*

### 🍏 Đóng gói ứng dụng cho hệ máy iOS
1. Tạo tệp lưu trữ ứng dụng (IPA) để chuẩn bị tải lên App Store Connect:
   ```bash
   flutter build ipa --release
   ```
   *Thực hiện các bước tiếp theo bằng cách mở thư mục `ios` trong Xcode để hoàn tất việc ký chứng chỉ nhà phát triển (Code Signing) và phân phối lên TestFlight.*
