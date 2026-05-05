// lib/services/progress_service.dart
// Handles persistence of memorized suras using shared_preferences.
// On web (Telegram Mini App) this maps to browser localStorage.

import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _key = 'memorized_suras';

  // Singleton pattern so we share one instance across the app
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  // In-memory set for fast lookups (synced with localStorage on load)
  final Set<int> _memorized = {};

  /// Call once at app startup to load saved data
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    _memorized.addAll(saved.map(int.parse));
  }

  bool isMemorized(int surahNumber) => _memorized.contains(surahNumber);

  int get memorizedCount => _memorized.length;

  Set<int> get memorizedSet => Set.unmodifiable(_memorized);

  /// Toggle a surah's memorized state and persist to storage
  Future<void> toggle(int surahNumber) async {
    if (_memorized.contains(surahNumber)) {
      _memorized.remove(surahNumber);
    } else {
      _memorized.add(surahNumber);
    }
    await _save();
  }

  Future<void> markMemorized(int surahNumber) async {
    _memorized.add(surahNumber);
    await _save();
  }

  /// Reset all progress
  Future<void> reset() async {
    _memorized.clear();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _memorized.map((e) => e.toString()).toList());
  }
}
