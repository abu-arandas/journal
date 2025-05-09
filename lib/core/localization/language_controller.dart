import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String languageCodeKey = 'languageCode';
  static const String countryCodeKey = 'countryCode';

  final RxString languageCode = 'en'.obs;
  final RxString countryCode = 'US'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Load the saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(languageCodeKey);
    final savedCountryCode = prefs.getString(countryCodeKey);

    if (savedLanguageCode != null && savedCountryCode != null) {
      languageCode.value = savedLanguageCode;
      countryCode.value = savedCountryCode;
      updateLocale();
    }
  }

  /// Update the app locale based on the current language code
  void updateLocale() {
    Get.updateLocale(Locale(languageCode.value, countryCode.value));
  }

  /// Change the app language
  Future<void> changeLanguage(String langCode, String countCode) async {
    languageCode.value = langCode;
    countryCode.value = countCode;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageCodeKey, langCode);
    await prefs.setString(countryCodeKey, countCode);

    // Update app locale
    updateLocale();
  }

  /// Get the current language name
  String get currentLanguageName {
    switch ('${languageCode.value}_${countryCode.value}') {
      case 'en_US':
        return 'English';
      case 'es_ES':
        return 'Español';
      case 'fr_FR':
        return 'Français';
      default:
        return 'English';
    }
  }

  /// Get the list of available languages
  List<Map<String, String>> get availableLanguages => [
    {'name': 'English', 'languageCode': 'en', 'countryCode': 'US'},
    {'name': 'Español', 'languageCode': 'es', 'countryCode': 'ES'},
    {'name': 'Français', 'languageCode': 'fr', 'countryCode': 'FR'},
  ];
}
