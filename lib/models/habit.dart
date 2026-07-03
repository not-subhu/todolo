import 'package:uuid/uuid.dart';

enum HabitFrequency { daily, weekdays, weekends, custom }
enum HabitCategory { health, study, fitness, mindfulness, social, creative, other }

class Habit {
  final String id;
  String name;
  String description;
  HabitFrequency frequency;
  HabitCategory category;
  List<DateTime> completionDates;
  int coinReward;
  String emoji;
  DateTime createdAt;
  List<int> customDays; // 1=Mon..7=Sun

  Habit({
    String? id,
    required this.name,
    this.description = '',
    this.frequency = HabitFrequency.daily,
    this.category = HabitCategory.other,
    List<DateTime>? completionDates,
    this.coinReward = 15,
    this.emoji = '⭐',
    DateTime? createdAt,
    List<int>? customDays,
  })  : id = id ?? const Uuid().v4(),
        completionDates = completionDates ?? [],
        createdAt = createdAt ?? DateTime.now(),
        customDays = customDays ?? [];

  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    final sorted = completionDates.map((d) => _dateOnly(d)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime check = _dateOnly(DateTime.now());

    // If not done today, start checking from yesterday
    if (sorted.isNotEmpty && !sorted.contains(check)) {
      check = check.subtract(const Duration(days: 1));
    }

    for (final d in sorted) {
      if (d == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (d.isBefore(check)) {
        break;
      }
    }
    return streak;
  }

  bool get isCompletedToday {
    final today = _dateOnly(DateTime.now());
    return completionDates.any((d) => _dateOnly(d) == today);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'frequency': frequency.index,
        'category': category.index,
        'completionDates':
            completionDates.map((d) => d.toIso8601String()).toList(),
        'coinReward': coinReward,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'customDays': customDays,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        frequency: HabitFrequency.values[json['frequency'] ?? 0],
        category: HabitCategory.values[json['category'] ?? 6],
        completionDates: (json['completionDates'] as List<dynamic>? ?? [])
            .map((d) => DateTime.parse(d as String))
            .toList(),
        coinReward: json['coinReward'] ?? 15,
        emoji: json['emoji'] ?? '⭐',
        createdAt: DateTime.parse(json['createdAt']),
        customDays: List<int>.from(json['customDays'] ?? []),
      );
}
