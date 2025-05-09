import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Theme settings
  final RxBool isDarkMode = false.obs;
  final RxInt selectedThemeIndex = 0.obs;

  // Reminder settings
  final RxBool isReminderEnabled = false.obs;
  final Rx<TimeOfDay> reminderTime = TimeOfDay(hour: 20, minute: 0).obs;

  // Privacy settings
  final RxBool isScreenshotAllowed = true.obs;

  // Default mood emojis/icons
  final RxList<String> moodOptions = <String>['😀', '😊', '🙂', '😐', '🙁', '😢', '😡'].obs;

  // Default activity tags
  final RxList<String> defaultTags =
      <String>['Work', 'Exercise', 'Family', 'Friends', 'Reading', 'Movies', 'Travel'].obs;

  // Keys for SharedPreferences
  static const String _darkModeKey = 'dark_mode';
  static const String _themeIndexKey = 'theme_index';
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _screenshotAllowedKey = 'screenshot_allowed';
  static const String _moodOptionsKey = 'mood_options';
  static const String _defaultTagsKey = 'default_tags';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme settings
    isDarkMode.value = prefs.getBool(_darkModeKey) ?? false;
    selectedThemeIndex.value = prefs.getInt(_themeIndexKey) ?? 0;

    // Load reminder settings
    isReminderEnabled.value = prefs.getBool(_reminderEnabledKey) ?? false;
    final hour = prefs.getInt(_reminderHourKey) ?? 20;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    reminderTime.value = TimeOfDay(hour: hour, minute: minute);

    // Load privacy settings
    isScreenshotAllowed.value = prefs.getBool(_screenshotAllowedKey) ?? true;

    // Load mood options and tags
    final savedMoods = prefs.getStringList(_moodOptionsKey);
    if (savedMoods != null && savedMoods.isNotEmpty) {
      moodOptions.value = savedMoods;
    }

    final savedTags = prefs.getStringList(_defaultTagsKey);
    if (savedTags != null && savedTags.isNotEmpty) {
      defaultTags.value = savedTags;
    }
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);

    // Update the app theme
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeIndex(int index) async {
    selectedThemeIndex.value = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeIndexKey, index);

    // You would implement custom theme changing here if needed
  }

  Future<void> setReminderEnabled(bool value) async {
    isReminderEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, value);

    // Handle reminder scheduling/cancelling here
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    reminderTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);

    // Update reminder if enabled
    if (isReminderEnabled.value) {
      // Reschedule the reminder with the new time
    }
  }

  Future<void> setScreenshotAllowed(bool value) async {
    isScreenshotAllowed.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenshotAllowedKey, value);
  }

  Future<void> addMoodOption(String mood) async {
    if (!moodOptions.contains(mood)) {
      moodOptions.add(mood);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_moodOptionsKey, moodOptions);
    }
  }

  Future<void> removeMoodOption(String mood) async {
    moodOptions.remove(mood);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_moodOptionsKey, moodOptions);
  }

  Future<void> reorderMoodOptions(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = moodOptions.removeAt(oldIndex);
    moodOptions.insert(newIndex, item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_moodOptionsKey, moodOptions);
  }

  Future<void> addDefaultTag(String tag) async {
    if (!defaultTags.contains(tag)) {
      defaultTags.add(tag);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_defaultTagsKey, defaultTags);
    }
  }

  Future<void> removeDefaultTag(String tag) async {
    defaultTags.remove(tag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_defaultTagsKey, defaultTags);
  }

  Future<void> reorderDefaultTags(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = defaultTags.removeAt(oldIndex);
    defaultTags.insert(newIndex, item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_defaultTagsKey, defaultTags);
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset to defaults
    isDarkMode.value = false;
    selectedThemeIndex.value = 0;
    isReminderEnabled.value = false;
    reminderTime.value = TimeOfDay(hour: 20, minute: 0);
    isScreenshotAllowed.value = true;

    moodOptions.value = ['😀', '😊', '🙂', '😐', '🙁', '😢', '😡'];
    defaultTags.value = ['Work', 'Exercise', 'Family', 'Friends', 'Reading', 'Movies', 'Travel'];

    // Update the app theme
    Get.changeThemeMode(ThemeMode.light);
  }
}
