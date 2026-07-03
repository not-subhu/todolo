import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/reward.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _tasksKey = 'kq_tasks';
  static const String _habitsKey = 'kq_habits';
  static const String _rewardsKey = 'kq_rewards';
  static const String _profileKey = 'kq_profile';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    // Idempotent — safe to call multiple times (e.g., from main() and from
    // AppProvider.initialize()). Only opens SharedPreferences once.
    _prefs ??= await SharedPreferences.getInstance();
    // Initialize with default rewards if empty
    final rewards = await getRewards();
    if (rewards.isEmpty) {
      for (final r in Reward.defaultRewards) {
        await saveReward(r);
      }
    }
  }

  // ── Tasks ──────────────────────────────────────────────
  Future<List<Task>> getTasks() async {
    final raw = _prefs?.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      tasks[idx] = task;
    } else {
      tasks.add(task);
    }
    await _prefs?.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _prefs?.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await _prefs?.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // ── Habits ──────────────────────────────────────────────
  Future<List<Habit>> getHabits() async {
    final raw = _prefs?.getString(_habitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Habit.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = await getHabits();
    final idx = habits.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) {
      habits[idx] = habit;
    } else {
      habits.add(habit);
    }
    await _prefs?.setString(
        _habitsKey, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> deleteHabit(String id) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == id);
    await _prefs?.setString(
        _habitsKey, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  // ── Rewards ──────────────────────────────────────────────
  Future<List<Reward>> getRewards() async {
    final raw = _prefs?.getString(_rewardsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Reward.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveReward(Reward reward) async {
    final rewards = await getRewards();
    final idx = rewards.indexWhere((r) => r.id == reward.id);
    if (idx >= 0) {
      rewards[idx] = reward;
    } else {
      rewards.add(reward);
    }
    await _prefs?.setString(
        _rewardsKey, jsonEncode(rewards.map((r) => r.toJson()).toList()));
  }

  Future<void> deleteReward(String id) async {
    final rewards = await getRewards();
    rewards.removeWhere((r) => r.id == id);
    await _prefs?.setString(
        _rewardsKey, jsonEncode(rewards.map((r) => r.toJson()).toList()));
  }

  // ── User Profile ──────────────────────────────────────────────
  Future<UserProfile> getProfile() async {
    final raw = _prefs?.getString(_profileKey);
    if (raw == null) return UserProfile();
    return UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs?.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
