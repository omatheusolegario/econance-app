import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDark = true;
  Locale _locale = const Locale('pt');

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'pt' ? const Locale('en') : const Locale('pt');
    notifyListeners();
  }
}
