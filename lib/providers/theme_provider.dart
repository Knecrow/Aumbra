import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;

  bool _reduceEffects = false;

  bool get isDarkMode => true;
  bool get reduceEffects => _reduceEffects;

  ThemeProvider({required LocalStorageService localStorage})
      : _localStorage = localStorage;

  Future<void> loadThemePreference() async {
    _reduceEffects = await _localStorage.getReduceEffects();
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
