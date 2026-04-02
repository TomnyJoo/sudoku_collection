import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题持久化存储类
class ThemePersistence {
  /// 主题模式存储键
  static const String _themeModeKey = 'theme_mode';
  
  /// 保存主题模式
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
  
  /// 加载主题模式
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      return ThemeMode.values.byName(themeModeString);
    }
    return ThemeMode.system; // 默认使用系统主题
  }
  
  /// 清除主题偏好
  static Future<void> clearThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
  }
}
