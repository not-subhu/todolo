import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/database_service.dart';

class HabitsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Habit> _habits = [];
  bool _isLoading = true;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  List<Habit> get pendingToday =>
      _habits.where((h) => !h.isCompletedToday).toList();

  int get completedTodayCount =>
      _habits.where((h) => h.isCompletedToday).length;

  int get totalStreak =>
      _habits.fold<int>(0, (acc, h) => acc + h.currentStreak);

  Future<void> load() async {
    _habits = await _db.getHabits();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _db.saveHabit(habit);
    _habits.add(habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.saveHabit(habit);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) _habits[idx] = habit;
    notifyListeners();
  }

  Future<int> checkInHabit(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx < 0) return 0;
    final habit = _habits[idx];
    if (habit.isCompletedToday) return 0;
    habit.completionDates.add(DateTime.now());
    await _db.saveHabit(habit);
    notifyListeners();
    return habit.coinReward;
  }

  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}
