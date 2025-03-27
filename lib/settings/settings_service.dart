import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'themeMode';
  static const String _colorSchemeSeedKey = 'colorSchemeSeed';

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
    final colorValue = prefs.getInt(_colorSchemeSeedKey) ?? Colors.lime.value;
    return Color(colorValue);
  }

  Future<void> updateColorSchemeSeed(Color colorSchemeSeed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorSchemeSeedKey, colorSchemeSeed.value);
  }
}
