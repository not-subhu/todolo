import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  UserProfile _profile = UserProfile();
  bool _isLoading = true;
  int _currentTab = 0;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  int get currentTab => _currentTab;

  Future<void> initialize() async {
    await _db.initialize();
    _profile = await _db.getProfile();
    _isLoading = false;
    notifyListeners();
  }

  void setTab(int tab) {
    _currentTab = tab;
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    _profile.addCoins(amount);
    await _db.saveProfile(_profile);
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (_profile.spendCoins(amount)) {
      await _db.saveProfile(_profile);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> incrementTasksCompleted() async {
    _profile.tasksCompleted++;
    _updateStreak();
    await _db.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> incrementHabitsCompleted() async {
    _profile.habitsCompleted++;
    _updateStreak();
    await _db.saveProfile(_profile);
    notifyListeners();
  }

  void _updateStreak() {
    final today = _dateOnly(DateTime.now());
    final last = _profile.lastActiveDate != null
        ? _dateOnly(_profile.lastActiveDate!)
        : null;

    if (last == null) {
      _profile.currentStreak = 1;
    } else if (today.difference(last).inDays == 1) {
      _profile.currentStreak++;
    } else if (today.difference(last).inDays > 1) {
      _profile.currentStreak = 1;
    }

    if (_profile.currentStreak > _profile.longestStreak) {
      _profile.longestStreak = _profile.currentStreak;
    }
    _profile.lastActiveDate = DateTime.now();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    await _db.saveProfile(_profile);
    notifyListeners();
  }
}
