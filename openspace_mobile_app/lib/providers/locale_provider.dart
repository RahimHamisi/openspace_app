// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';

import '../service/preference_service.dart';


class LocaleProvider with ChangeNotifier {
  final PreferenceService preferenceService = PreferenceService();
  String _locale = 'en';

  String get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _locale = await preferenceService.getLanguage() ?? 'en';
    notifyListeners();
  }

  void setLocale(String locale) {
    _locale = locale;
    preferenceService.saveLanguage(locale);
    notifyListeners();
  }
}