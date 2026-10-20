import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/semester.dart';

class AppStore extends ChangeNotifier {
  static const String defaultEmail = 'kazishihab248@gmail.com';
  static const String defaultPassword = '00000000';

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
  String userEmail = '';
  Map<String, Map<String, String>> _users = <String, Map<String, String>>{};
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
    userEmail = prefs!.getString('userEmail') ?? '';

    final rawUsers = prefs!.getString('users');
    if (rawUsers != null && rawUsers.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUsers);
        if (decoded is Map) {
          _users = decoded.map<String, Map<String, String>>((key, value) {
            if (value is Map) {
              final profile = <String, String>{};
              value.forEach((innerKey, innerValue) {
                profile[innerKey.toString()] = innerValue.toString();
              });
              return MapEntry(key.toString(), profile);
            }
            return MapEntry(key.toString(), <String, String>{});
          });
        }
      } catch (_) {
        _users = <String, Map<String, String>>{};
      }
    }

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

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  bool _isDefaultCredentials(String email, String password) {
    return _normalizeEmail(email) == defaultEmail &&
        password.trim() == defaultPassword;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String id = '',
    String uni = '',
  }) async {
    final cleanName = name.trim();
    final normalizedEmail = _normalizeEmail(email);
    final cleanPassword = password.trim();

    if (!_isDefaultCredentials(normalizedEmail, cleanPassword)) {
      throw Exception('Only the default admin account is allowed.');
    }

    if (cleanName.isEmpty) throw Exception('Please enter your name');
    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Please enter a valid email address');
    }

    _users[normalizedEmail] = {
      'password': defaultPassword,
      'name': cleanName,
      'id': id.trim(),
      'uni': uni.trim(),
    };

    loggedIn = true;
    onboardingComplete = true;
    studentName = cleanName;
    studentId = id.trim();
    university = uni.trim();
    userEmail = normalizedEmail;
    await _save();
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    final cleanPassword = password.trim();

    if (!_isDefaultCredentials(normalizedEmail, cleanPassword)) {
      throw Exception('Invalid email or password');
    }

    final profile = _users[normalizedEmail] ?? <String, String>{};

    loggedIn = true;
    onboardingComplete = true;
    studentName = profile['name']?.trim().isNotEmpty == true
        ? profile['name']!
        : 'Student';
    studentId = profile['id'] ?? '';
    university = profile['uni'] ?? '';
    userEmail = normalizedEmail;
    await _save();
    notifyListeners();
  }

  Future<void> login(String name, String id, String uni) async {
    final normalizedEmail = userEmail.isNotEmpty ? userEmail : defaultEmail;
    final defaultMatch =
        _isDefaultCredentials(normalizedEmail, defaultPassword);

    if (!defaultMatch) {
      throw Exception('This app only allows the default login account.');
    }

    loggedIn = true;
    onboardingComplete = true;
    studentName = name.trim().isEmpty ? 'Student' : name.trim();
    studentId = id.trim();
    university = uni.trim();
    userEmail = normalizedEmail;
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

    if (userEmail.isNotEmpty) {
      final profile = _users[_normalizeEmail(userEmail)];
      if (profile != null) {
        profile['name'] = studentName;
        profile['id'] = studentId;
        profile['uni'] = university;
      }
    }

    await _save();
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    userEmail = '';
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
    await prefs!.setString('userEmail', userEmail);
    await prefs!.setString('users', jsonEncode(_users));
    await prefs!.setString(
      'history',
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
    await prefs!.setString('scale', jsonEncode(scale));
  }
}
