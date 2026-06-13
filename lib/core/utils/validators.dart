class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Phải có ít nhất 1 chữ hoa';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Phải có ít nhất 1 số';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập username';
    if (value.length < 3) return 'Username phải có ít nhất 3 ký tự';
    if (value.length > 20) return 'Username không quá 20 ký tự';
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) return 'Chỉ dùng chữ cái, số và dấu gạch dưới';
    return null;
  }

  static String? waterAmount(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập lượng nước';
    final amount = int.tryParse(value);
    if (amount == null) return 'Giá trị không hợp lệ';
    if (amount < 1) return 'Tối thiểu 1ml';
    if (amount > 5000) return 'Tối đa 5000ml';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'thông tin'}';
    }
    return null;
  }

  static double passwordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    return strength;
  }
}
