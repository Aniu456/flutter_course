import 'package:flutter/material.dart';

/// 全局 App 设置：主题模式 + 语言。
///
/// 这里用最朴素的 ChangeNotifier + 全局单例实现，方便课程演示；
/// 真实项目可换成 Provider / Riverpod 等状态管理方案，并用
/// shared_preferences 持久化（参见「本地存储」分类）。
class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale; // null 表示跟随系统语言

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }

  set locale(Locale? value) {
    if (value == _locale) return;
    _locale = value;
    notifyListeners();
  }
}

/// 整个 App 共用的设置实例，MyApp 监听它来切换主题与语言。
final AppSettings appSettings = AppSettings();
