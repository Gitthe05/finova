import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/theme_preferences.dart';

final themePreferencesProvider = Provider((ref) => ThemePreferences());

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(themePreferencesProvider));
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(ThemeMode.light) {
    _init();
  }

  final ThemePreferences _prefs;
  final _ready = Completer<void>();

  Future<void> ensureInitialized() => _ready.future;

  Future<void> _init() async {
    try {
      state = await _prefs.load();
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode != ThemeMode.light && mode != ThemeMode.dark) return;
    if (state == mode) return;
    await _prefs.save(mode);
    state = mode;
  }

  bool get isDark => state == ThemeMode.dark;
}
