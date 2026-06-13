import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  String timeAgo(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return context.tr('common.timeAgoJustNow');
    if (diff.inMinutes < 60) return context.tr('common.timeAgoMinutes').replaceAll('{value}', '${diff.inMinutes}');
    if (diff.inHours < 24) return context.tr('common.timeAgoHours').replaceAll('{value}', '${diff.inHours}');
    if (diff.inDays < 7) return context.tr('common.timeAgoDays').replaceAll('{value}', '${diff.inDays}');
    if (diff.inDays < 30) return context.tr('common.timeAgoWeeks').replaceAll('{value}', '${(diff.inDays / 7).floor()}');
    if (diff.inDays < 365) return context.tr('common.timeAgoMonths').replaceAll('{value}', '${(diff.inDays / 30).floor()}');
    return context.tr('common.timeAgoYears').replaceAll('{value}', '${(diff.inDays / 365).floor()}');
  }

  String get formatDate => DateFormat('dd/MM/yyyy').format(this);
  String get formatTime => DateFormat('HH:mm').format(this);
  String get formatDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
  String get formatDayName => DateFormat('EEEE').format(this);
  String get formatShortDay => DateFormat('E').format(this);
  String get formatMonthDay => DateFormat('dd MMM').format(this);

  String greeting(BuildContext context) {
    final hour = this.hour;
    if (hour < 6) return context.tr('common.greetingLateNight');
    if (hour < 12) return context.tr('common.greetingMorning');
    if (hour < 18) return context.tr('common.greetingAfternoon');
    return context.tr('common.greetingEvening');
  }

  String get greetingEmoji {
    final hour = this.hour;
    if (hour < 6) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌙';
  }
}

extension StringX on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get initials {
    if (isEmpty) return '';
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return this[0].toUpperCase();
  }
}

extension NumX on num {
  String get toMl {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}L';
    }
    return '${toInt()}ml';
  }

  String get toLiters => '${(this / 1000).toStringAsFixed(1)}L';

  String get toXpString {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}k XP';
    }
    return '${toInt()} XP';
  }
}

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

extension ListX<T> on List<T> {
  T? get safeFirst => isEmpty ? null : first;
  T? safeElementAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
