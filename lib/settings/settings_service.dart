import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'themeMode';
  static const String _colorSchemeSeedKey = 'colorSchemeSeed';
  static const String _lastVisitedListIdKey = 'lastVisitedListId';

  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, theme.index);
  }

  Future<Color> colorSchemeSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_colorSchemeSeedKey) ?? Colors.lime.toARGB32();
    return Color(colorValue);
  }

  Future<void> updateColorSchemeSeed(Color colorSchemeSeed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorSchemeSeedKey, colorSchemeSeed.toARGB32());
  }

  Future<String?> lastVisitedListId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastVisitedListIdKey);
  }

  Future<void> updateLastVisitedListId(String? listId) async {
    final prefs = await SharedPreferences.getInstance();
    if (listId == null) {
      await prefs.remove(_lastVisitedListIdKey);
    } else {
      await prefs.setString(_lastVisitedListIdKey, listId);
    }
  }
}
