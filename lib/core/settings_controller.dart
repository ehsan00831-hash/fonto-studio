import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings: language, theme, and workspace accent colour.
class SettingsController extends ChangeNotifier {
  Locale _locale = const Locale('fa');
  ThemeMode _themeMode = ThemeMode.dark;
  int _workspaceColor = 0xFF7C4DFF;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  Color get workspaceColor => Color(_workspaceColor);
  int get workspaceColorValue => _workspaceColor;
  bool get isFa => _locale.languageCode == 'fa';

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString('locale') ?? 'fa');
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.dark.index];
    _workspaceColor = prefs.getInt('workspaceColor') ?? 0xFF7C4DFF;
    notifyListeners();
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _locale.languageCode);
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setInt('workspaceColor', _workspaceColor);
  }

  void setLocale(Locale l) {
    _locale = l;
    _save();
    notifyListeners();
  }

  void toggleLanguage() => setLocale(isFa ? const Locale('en') : const Locale('fa'));

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    _save();
    notifyListeners();
  }

  void setWorkspaceColor(int value) {
    _workspaceColor = value;
    _save();
    notifyListeners();
  }
}
