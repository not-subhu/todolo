import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../services/todoist_service.dart';

class TasksProvider extends ChangeNotifier {
  final _db = DatabaseService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get todayTasks => _tasks
      .where((t) => t.isToday && t.status == TaskStatus.pending)
      .toList();

  List<Task> get overdueTasks => _tasks
      .where((t) => t.isOverdue && t.status == TaskStatus.pending)
      .toList();

  List<Task> get upcomingTasks => _tasks
      .where((t) =>
          !t.isToday && !t.isOverdue &&
          t.status == TaskStatus.pending && t.dueDate != null)
      .toList();

  List<Task> get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending && !t.isHabit).toList();

  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();

  int get pendingCount =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;

  /// Called when both AI models are unavailable and pester generation was queued.
  Function()? _onPesterQueued;
  void setOnPesterQueued(Function() cb) => _onPesterQueued = cb;

  Future<void> load() async {
    _tasks = await _db.getTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _db.saveTask(task);
    _tasks.add(task);
    notifyListeners();
    // Fire-and-forget pester generation; queue retry if both models unavailable.
    _triggerPesterGeneration(task);
  }

  void _triggerPesterGeneration(Task task) {
    NotificationService()
        .generatePesterBatchForTask(task)
        .then((success) {
      if (!success) _onPesterQueued?.call();
    }).catchError((_) {});
  }

  Future<void> addTasks(List<Task> newTasks) async {
    for (final t in newTasks) {
      await _db.saveTask(t);
      _tasks.add(t);
      _triggerPesterGeneration(t);
    }
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.saveTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _tasks[idx] = task;
    notifyListeners();
  }

  Future<int> completeTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return 0;
    final task = _tasks[idx].copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    _tasks[idx] = task;
    await _db.saveTask(task);
    // Clear pester messages for this task — it's done.
    await _db.deletePesterMessages(id);
    notifyListeners();
    return task.coinReward;
  }

  Future<void> uncompleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final task = _tasks[idx].copyWith(status: TaskStatus.pending);
    _tasks[idx] = task;
    await _db.saveTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    await _db.deletePesterMessages(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<List<Task>> parseFromText(String text, String apiKey) async {
    if (apiKey.isEmpty) throw Exception('No Gemini API key set');
    final svc = GeminiService(apiKey);
    final parsed = await svc.parseTasksFromText(text);
    return parsed.map((p) => p.toTask()).toList();
  }

  Future<int> syncFromTodoist(String token) async {
    final svc = TodoistService(token);
    final remoteTasks = await svc.fetchTasks();
    int added = 0;
    for (final rt in remoteTasks) {
      final exists = _tasks.any((t) => t.todoistId == rt.todoistId);
      if (!exists) {
        await _db.saveTask(rt);
        _tasks.add(rt);
        added++;
      }
    }
    notifyListeners();
    return added;
  }
}
