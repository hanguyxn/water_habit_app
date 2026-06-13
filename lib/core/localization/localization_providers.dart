import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('vi'));

  void setLocale(Locale locale) {
    if (state != locale) {
      state = locale;
    }
  }

  void toggleLocale() {
    if (state.languageCode == 'vi') {
      state = const Locale('en');
    } else {
      state = const Locale('vi');
    }
  }
}
