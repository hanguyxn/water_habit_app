# Danh sách các hạng mục đã hoàn thành 🌿

Tài liệu này tổng hợp cấu trúc thư mục, các tính năng chính và cơ chế vận hành đã được xây dựng cho dự án **Water Habit App**.

---

## 📁 Cấu trúc thư mục mã nguồn (`lib/`)

Mã nguồn được tổ chức theo cấu trúc Clean Architecture hướng tính năng (feature-first) để dễ dàng bảo trì và mở rộng:

```
lib/
├── app.dart                               # Root widget (Cài đặt Theme, Router, Locales)
├── main.dart                              # Điểm khởi chạy ứng dụng (WidgetsFlutterBinding, System Chrome)
├── core/                                  # Tài nguyên dùng chung của toàn bộ ứng dụng
│   ├── constants/
│   │   ├── app_constants.dart             # Hằng số cấu hình mục tiêu nước, chuỗi ngày, kích thước cốc...
│   │   └── firestore_paths.dart           # Đường dẫn đến các Collection/Document trong Firestore
│   ├── localization/
│   │   ├── app_localizations.dart         # Từ điển dịch Việt/Anh và Extension context.tr()
│   │   └── localization_providers.dart    # Riverpod provider quản lý & chuyển đổi ngôn ngữ
│   ├── providers/
│   │   ├── auth_provider.dart             # Provider quản lý Firebase Auth & Firestore User state
│   │   └── theme_provider.dart            # Provider quản lý chế độ Sáng/Tối/Hệ thống
│   ├── theme/
│   │   ├── app_colors.dart                # Bảng màu Nature-inspired (Gradients, HSL colors)
│   │   ├── app_decorations.dart           # Kiểu bo góc, đổ bóng (Nature shadows)
│   │   ├── app_theme.dart                 # Cấu hình ThemeData Light & Dark cho Flutter
│   │   └── app_typography.dart            # Cấu hình phông chữ Nunito & Quicksand
│   ├── utils/
│   │   ├── extensions.dart                # Tiện ích mở rộng định dạng thời gian (timeAgo), lời chào (greeting)...
│   │   └── validators.dart                # Biểu thức chính quy kiểm tra định dạng email, mật khẩu...
│   └── widgets/
│       ├── animated_list_item.dart        # Hiệu ứng cuộn danh sách mượt mà
│       ├── app_avatar.dart                # Widget hiển thị ảnh đại diện hoặc chữ cái đầu tiên của tên
│       ├── app_bottom_nav.dart            # Thanh điều hướng phía dưới tùy biến đẹp mắt
│       ├── app_button.dart                # Nút bấm tùy chỉnh trạng thái loading
│       ├── app_card.dart                  # Bo góc bóng đổ dùng chung cho các thành phần UI
│       ├── app_error_widget.dart          # Widget hiển thị lỗi thân thiện kèm nút thử lại
│       ├── app_text_field.dart            # Ô nhập liệu có hoạt ảnh chuyển màu viền khi focus
│       ├── empty_state_widget.dart        # Trạng thái rỗng kèm hình ảnh minh họa và nút hành động
│       ├── loading_widget.dart            # Màn hình chờ phong cách tối giản
│       └── streak_badge.dart              # Huy hiệu ngọn lửa hiển thị chuỗi ngày liên tục uống nước
├── features/                              # Các mô-đun chức năng độc lập
│   ├── auth/                              # Xác thực tài khoản
│   │   ├── data/auth_repository.dart      # Đăng nhập, đăng ký, đăng xuất tương tác với Firebase
│   │   ├── domain/user_model.dart         # Đối tượng UserModel định nghĩa thông tin tài khoản
│   │   ├── presentation/
│   │   │   ├── login_screen.dart          # Màn hình đăng nhập đẹp mắt kèm nút mạng xã hội
│   │   │   ├── register_screen.dart       # Màn hình đăng ký có kiểm tra độ mạnh mật khẩu
│   │   │   └── widgets/
│   │   │       └── social_login_buttons.dart # Các nút đăng nhập bằng Google, Apple
│   │   └── providers/auth_providers.dart  # Riverpod Auth providers
│   ├── feed/                              # Bảng tin hoạt động xã hội
│   │   ├── data/feed_repository.dart      # Truy vấn dữ liệu bài đăng hoạt động của bạn bè
│   │   ├── domain/feed_item_model.dart    # Đối tượng FeedItem (mục tiêu hoàn thành, lên cấp...)
│   │   ├── presentation/
│   │   │   ├── feed_screen.dart           # Bảng tin hiển thị bài đăng và hoạt ảnh thả biểu cảm
│   │   │   └── widgets/
│   │   │       └── feed_card.dart         # Thẻ hoạt động động tích hợp popover biểu cảm (❤️, 🌱, 🔥, 💧)
│   │   └── providers/feed_providers.dart  # Bảng tin Riverpod providers
│   ├── friends/                           # Quản lý bạn bè
│   │   ├── data/friend_repository.dart    # Xử lý kết bạn, chấp nhận lời mời, tìm kiếm
│   │   ├── domain/friend_model.dart       # Định nghĩa đối tượng bạn bè
│   │   ├── domain/friend_request_model.dart # Lời mời kết bạn (gửi đi/nhận về)
│   │   ├── presentation/
│   │   │   ├── friends_screen.dart        # Quản lý danh sách bạn bè & xử lý lời mời kết bạn (tabbed view)
│   │   │   ├── friend_search_screen.dart  # Tìm kiếm bạn bè, tích hợp phím tắt QR Code
│   │   │   └── widgets/
│   │   │       ├── friend_card.dart       # Hiển thị thông tin bạn bè, cấp độ và ngọn lửa chuỗi ngày
│   │   │       └── friend_request_card.dart # Xử lý chấp nhận/hủy lời mời kết bạn
│   │   └── providers/friends_providers.dart # Riverpod Friends providers
│   ├── profile/                           # Hồ sơ cá nhân & Thành tích
│   │   ├── data/profile_repository.dart   # Cập nhật thông tin, tải thành tích, lấy biểu đồ tuần
│   │   ├── domain/profile_model.dart      # Định nghĩa thống kê (ProfileStats), huy hiệu (Achievement)...
│   │   ├── presentation/
│   │   │   ├── edit_profile_screen.dart   # Form chỉnh sửa cá nhân, đổi mục tiêu nước & chuyển ngôn ngữ vi/en
│   │   │   ├── profile_screen.dart        # Xem thông tin cá nhân, biểu đồ tuần, bộ sưu tập huy hiệu
│   │   │   └── widgets/
│   │   │       ├── profile_header.dart    # Header hồ sơ màu chuyển sắc, vòng tròn XP, ngọn lửa
│   │   │       ├── stats_card.dart        # Hiển thị thông số (Tổng nước, Chuỗi tốt nhất) kèm đếm số chạy
│   │   │       └── weekly_chart.dart      # Biểu đồ cột fl_chart chi tiết lượng nước uống 7 ngày gần nhất
│   │   └── providers/profile_providers.dart # Riverpod Profile providers
│   └── splash/                            # Màn hình chờ khởi động ứng dụng
│       └── presentation/
│           └── splash_screen.dart         # Hoạt ảnh logo giọt nước rơi mượt mà, tự động chuyển hướng đăng nhập
├── models/
│   └── enums/                             # Các cấu trúc enum số hóa (numeric values) theo chuẩn
│       ├── feed_event_type_enum.dart
│       ├── friend_status_enum.dart
│       ├── leaderboard_type_enum.dart
│       ├── reaction_type_enum.dart
│       └── seasonal_rank_enum.dart
└── routing/                               # Điều hướng ứng dụng
    ├── app_router.dart                    # Cấu hình GoRouter bảo vệ (Route Guards), Bottom Navigation
    └── route_names.dart                   # Định nghĩa tên của các đường dẫn
```

---

## 💎 Điểm nhấn Thiết kế & Công nghệ đã triển khai

1. **Giao diện chuẩn Premium (Nature-Inspired)**:
   - Sử dụng bảng màu xanh thiên nhiên tươi mát kết hợp màu gỗ sáng, xám khói, và chế độ tối (Dark Mode) có độ tương phản cao chống mỏi mắt.
   - Các chuyển động mượt mà được tăng cường bởi thư viện `flutter_animate` (Fade-in, Elastic bounce, Slide, Scale).
   
2. **Hệ thống Đa ngôn ngữ (Internationalization - i18n)**:
   - Thiết kế hệ thống dịch gọn nhẹ, tối ưu hóa qua Riverpod mà không phụ thuộc vào công cụ tạo mã cồng kềnh.
   - Cho phép người dùng chuyển đổi trực tiếp giữa **Tiếng Việt** và **Tiếng Anh** ngay trong ứng dụng với tốc độ cập nhật tức thời (real-time reload).

3. **Cơ chế Gamification độc đáo**:
   - Vòng tròn cấp độ (Level) chạy theo điểm kinh nghiệm (XP) của người dùng xung quanh ảnh đại diện.
   - Ngọn lửa chuỗi ngày (Streak) khích lệ người dùng duy trì thói quen uống nước đều đặn.
   - Các huy hiệu (Achievements) được phân chia theo phân khúc tier (Bronze, Silver, Gold, Diamond) hiển thị tuyệt đẹp.

4. **Biểu đồ trực quan và Thống kê**:
   - Tích hợp biểu đồ cột `fl_chart` hiển thị lượng nước uống hàng ngày so với mục tiêu đề ra.
   - Cột nước được phân loại màu thông minh: Đạt mục tiêu (Xanh lá), Đang uống (Xanh lam), Chưa uống (Xám).
