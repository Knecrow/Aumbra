import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;

  bool _isDarkMode = true;
  bool _reduceEffects = false;

  bool get isDarkMode => _isDarkMode;
  bool get reduceEffects => _reduceEffects;

  ThemeProvider({required LocalStorageService localStorage})
      : _localStorage = localStorage;

  Future<void> loadThemePreference() async {
    _isDarkMode = await _localStorage.isDarkMode();
    _reduceEffects = await _localStorage.getReduceEffects();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _localStorage.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _localStorage.setDarkMode(value);
    notifyListeners();
  }

  Future<void> toggleReduceEffects() async {
    _reduceEffects = !_reduceEffects;
    await _localStorage.setReduceEffects(_reduceEffects);
    notifyListeners();
  }

  Future<void> setReduceEffects(bool value) async {
    _reduceEffects = value;
    await _localStorage.setReduceEffects(value);
    notifyListeners();
  }
}
