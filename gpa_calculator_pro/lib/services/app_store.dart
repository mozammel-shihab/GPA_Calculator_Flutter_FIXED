import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/semester.dart';

class AppStore extends ChangeNotifier {
  AppStore._(this.prefs) {
    _load();
  }

  final SharedPreferences? prefs;

  bool loggedIn = false;
  bool onboardingComplete = false;
  bool darkMode = false;
  String studentName = 'Student';
  String studentId = '';
  String university = '';
  Map<String, double> scale = Map<String, double>.from(defaultScale);
  List<SemesterRecord> history = <SemesterRecord>[];

  static Future<AppStore> create() async {
    try {
      return AppStore._(await SharedPreferences.getInstance());
    } catch (_) {
      return AppStore._(null);
    }
  }

  void _load() {
    if (prefs == null) {
      scale = Map<String, double>.from(defaultScale);
      history = <SemesterRecord>[];
      return;
    }

    loggedIn = prefs!.getBool('loggedIn') ?? false;
    onboardingComplete = prefs!.getBool('onboardingComplete') ?? loggedIn;
    darkMode = prefs!.getBool('darkMode') ?? false;
    studentName = prefs!.getString('studentName') ?? 'Student';
    studentId = prefs!.getString('studentId') ?? '';
    university = prefs!.getString('university') ?? '';

    final rawHistory = prefs!.getString('history');
    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHistory);
        if (decoded is List) {
          history = decoded
              .whereType<Map>()
              .map((e) => SemesterRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (_) {
        history = <SemesterRecord>[];
      }
    }

    final rawScale = prefs!.getString('scale');
    if (rawScale != null && rawScale.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawScale);
        if (decoded is Map) {
          final loaded = <String, double>{};
          decoded.forEach((key, value) {
            if (value is num) loaded[key.toString()] = value.toDouble();
          });
          if (loaded.isNotEmpty) scale = loaded;
        }
      } catch (_) {
        scale = Map<String, double>.from(defaultScale);
      }
    }
  }

  Future<void> login(String name, String id, String uni) async {
    loggedIn = true;
    onboardingComplete = true;
    studentName = name.trim().isEmpty ? 'Student' : name.trim();
    studentId = id.trim();
    university = uni.trim();
    await _save();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    await _save();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String id, String uni) async {
    studentName = name.trim().isEmpty ? 'Student' : name.trim();
    studentId = id.trim();
    university = uni.trim();
    await _save();
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    await _save();
    notifyListeners();
  }

  Future<void> toggleDark() async {
    darkMode = !darkMode;
    await _save();
    notifyListeners();
  }

  Future<void> addRecord(SemesterRecord record) async {
    history.insert(0, record);
    await _save();
    notifyListeners();
  }

  Future<void> removeRecord(int index) async {
    if (index < 0 || index >= history.length) return;
    history.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _save();
    notifyListeners();
  }

  Future<void> setScale(Map<String, double> newScale) async {
    scale = Map<String, double>.from(newScale);
    await _save();
    notifyListeners();
  }

  Future<void> resetScale() async {
    scale = Map<String, double>.from(defaultScale);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    if (prefs == null) return;

    await prefs!.setBool('loggedIn', loggedIn);
    await prefs!.setBool('onboardingComplete', onboardingComplete);
    await prefs!.setBool('darkMode', darkMode);
    await prefs!.setString('studentName', studentName);
    await prefs!.setString('studentId', studentId);
    await prefs!.setString('university', university);
    await prefs!.setString(
      'history',
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
    await prefs!.setString('scale', jsonEncode(scale));
  }
}
