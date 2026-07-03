import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, completed, overdue }

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  TimeOfDayData? dueTime;
  TaskPriority priority;
  TaskStatus status;
  int coinReward;
  List<String> tags;
  bool isHabit;
  DateTime createdAt;
  DateTime? completedAt;
  String? todoistId;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    int? coinReward,
    List<String>? tags,
    this.isHabit = false,
    DateTime? createdAt,
    this.completedAt,
    this.todoistId,
  })  : id = id ?? const Uuid().v4(),
        coinReward = coinReward ?? _defaultCoins(priority),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  static int _defaultCoins(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 5;
      case TaskPriority.medium:
        return 10;
      case TaskPriority.high:
        return 20;
      case TaskPriority.urgent:
        return 30;
    }
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    final now = DateTime.now();
    if (dueTime != null) {
      // Has a specific time — overdue once that moment passes.
      final deadline = DateTime(
          dueDate!.year, dueDate!.month, dueDate!.day,
          dueTime!.hour, dueTime!.minute);
      return now.isAfter(deadline);
    }
    // Date-only task: overdue only when the due *date* is before today
    // (i.e. yesterday or earlier). Today's tasks are never "overdue" until
    // midnight of the following day.
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDay.isBefore(today);
  }

  bool get isToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime?.toJson(),
        'priority': priority.index,
        'status': status.index,
        'coinReward': coinReward,
        'tags': tags,
        'isHabit': isHabit,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'todoistId': todoistId,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateSafe(String? s) {
      if (s == null) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    return Task(
      id: json['id'],
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? '',
      dueDate: parseDateSafe(json['dueDate']),
      dueTime: json['dueTime'] != null
          ? TimeOfDayData.fromJson(Map<String, dynamic>.from(json['dueTime']))
          : null,
      priority: TaskPriority.values[
          (json['priority'] as int?)?.clamp(0, TaskPriority.values.length - 1) ?? 1],
      status: TaskStatus.values[
          (json['status'] as int?)?.clamp(0, TaskStatus.values.length - 1) ?? 0],
      coinReward: json['coinReward'] ?? 10,
      tags: List<String>.from(json['tags'] ?? []),
      isHabit: json['isHabit'] ?? false,
      createdAt: parseDateSafe(json['createdAt']) ?? DateTime.now(),
      completedAt: parseDateSafe(json['completedAt']),
      todoistId: json['todoistId'],
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDayData? dueTime,
    TaskPriority? priority,
    TaskStatus? status,
    int? coinReward,
    List<String>? tags,
    DateTime? completedAt,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        dueTime: dueTime ?? this.dueTime,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        coinReward: coinReward ?? this.coinReward,
        tags: tags ?? this.tags,
        isHabit: isHabit,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
        todoistId: todoistId,
      );
}

class TimeOfDayData {
  final int hour;
  final int minute;

  const TimeOfDayData({required this.hour, required this.minute});

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};
  factory TimeOfDayData.fromJson(Map<String, dynamic> j) =>
      TimeOfDayData(hour: j['hour'], minute: j['minute']);

  @override
  String toString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
