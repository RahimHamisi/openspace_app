import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static String currentLanguage = "en";

  static final Map<String, Map<String, String>> _translations = {
    "en": {
      "settings": "Settings",
      "language": "Language",
      "help_support": "Help & Support",
      "terms_conditions": "Terms & Conditions",
      "privacy_policy": "Privacy Policy",
      "dark_mode": "Dark Mode",
      "notifications": "Notifications",
      "logout": "Logout",
    },
    "sw": {
      "settings": "Mipangilio",
      "language": "Lugha",
      "help_support": "Msaada & Usaidizi",
      "terms_conditions": "Masharti & Sheria",
      "privacy_policy": "Sera ya Faragha",
      "dark_mode": "Mandhari ya Giza",
      "notifications": "Arifa",
      "logout": "Ondoka",
    },
  };

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", language);
    currentLanguage = language;
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage = prefs.getString("app_language") ?? "en";
  }

  static String getTranslation(String key) {
    return _translations[currentLanguage]?[key] ?? key;
  }
}
