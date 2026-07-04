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

  static const String _tasksKey   = 'sc_tasks';
  static const String _habitsKey  = 'sc_habits';
  static const String _rewardsKey = 'sc_rewards';
  static const String _profileKey = 'sc_profile';
  static const String _pesterPfx  = 'sc_pester_';   // + taskId
  static const String _pendingAiKey = 'sc_pending_ai';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    final rewards = await getRewards();
    if (rewards.isEmpty) {
      for (final r in Reward.defaultRewards) {
        await saveReward(r);
      }
    }
  }

  // ── Tasks ────────────────────────────────────────────────────────────────
  Future<List<Task>> getTasks() async {
    final raw = _prefs?.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Task.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) { tasks[idx] = task; } else { tasks.add(task); }
    await _prefs?.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _prefs?.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await _prefs?.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // ── Habits ───────────────────────────────────────────────────────────────
  Future<List<Habit>> getHabits() async {
    final raw = _prefs?.getString(_habitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Habit.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = await getHabits();
    final idx = habits.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) { habits[idx] = habit; } else { habits.add(habit); }
    await _prefs?.setString(_habitsKey, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> deleteHabit(String id) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == id);
    await _prefs?.setString(_habitsKey, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  // ── Rewards ──────────────────────────────────────────────────────────────
  Future<List<Reward>> getRewards() async {
    final raw = _prefs?.getString(_rewardsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Reward.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveReward(Reward reward) async {
    final rewards = await getRewards();
    final idx = rewards.indexWhere((r) => r.id == reward.id);
    if (idx >= 0) { rewards[idx] = reward; } else { rewards.add(reward); }
    await _prefs?.setString(_rewardsKey, jsonEncode(rewards.map((r) => r.toJson()).toList()));
  }

  Future<void> deleteReward(String id) async {
    final rewards = await getRewards();
    rewards.removeWhere((r) => r.id == id);
    await _prefs?.setString(_rewardsKey, jsonEncode(rewards.map((r) => r.toJson()).toList()));
  }

  // ── User Profile ─────────────────────────────────────────────────────────
  Future<UserProfile> getProfile() async {
    final raw = _prefs?.getString(_profileKey);
    if (raw == null) return UserProfile();
    return UserProfile.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs?.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // ── Pester message cache (per task) ──────────────────────────────────────
  Future<List<String>> getPesterMessages(String taskId) async {
    final raw = _prefs?.getString('$_pesterPfx$taskId');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> savePesterMessages(String taskId, List<String> messages) async {
    await _prefs?.setString('$_pesterPfx$taskId', jsonEncode(messages));
  }

  Future<void> deletePesterMessages(String taskId) async {
    await _prefs?.remove('$_pesterPfx$taskId');
  }

  // ── Pending AI retry queue ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPendingAi() async {
    final raw = _prefs?.getString(_pendingAiKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> savePendingAi(List<Map<String, dynamic>> pending) async {
    await _prefs?.setString(_pendingAiKey, jsonEncode(pending));
  }
}
