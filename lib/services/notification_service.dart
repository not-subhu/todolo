import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/gemini_service.dart';

/// On mobile this wraps flutter_local_notifications.
/// On web (Replit preview) it manages an in-app overlay callback.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _pesterTimer;
  Function(String message)? _onPester;
  String? _geminiKey;
  String _username = 'Student-chan';

  void configure({
    required String username,
    String? geminiKey,
    required Function(String) onPester,
  }) {
    _username = username;
    _geminiKey = geminiKey;
    _onPester = onPester;
  }

  void startPestering({
    required List<Task> pendingTasks,
    required int intervalMinutes,
  }) {
    stopPestering();
    if (pendingTasks.isEmpty) return;

    _pesterTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => _triggerPester(pendingTasks),
    );
  }

  void stopPestering() {
    _pesterTimer?.cancel();
    _pesterTimer = null;
  }

  Future<void> _triggerPester(List<Task> tasks) async {
    final overdue = tasks.where((t) => t.isOverdue).toList();
    final today = tasks.where((t) => t.isToday && !t.isOverdue).toList();
    final task = overdue.isNotEmpty
        ? overdue.first
        : today.isNotEmpty
            ? today.first
            : tasks.first;

    String message;
    if (_geminiKey != null && _geminiKey!.isNotEmpty) {
      try {
        final svc = GeminiService(_geminiKey!);
        message = await svc.generatePesterMessage(
          taskTitle: task.title,
          username: _username,
          isUrgent: task.isOverdue,
        );
      } catch (_) {
        message = _fallback(task.title, task.isOverdue);
      }
    } else {
      message = _fallback(task.title, task.isOverdue);
    }

    _onPester?.call(message);
  }

  String _fallback(String taskTitle, bool urgent) {
    final messages = [
      'Yare yare... "$taskTitle" is still unfinished, $_username-san. Even the universe is waiting. (｡•́︿•̀｡)',
      'NANI?! "$taskTitle" hasn\'t been touched yet?! This is your FINAL BOSS moment! ٩(ఠ益ఠ)۶',
      'H-hey $_username... I\'m not angry, I\'m just... really disappointed about "$taskTitle". (；´д｀)ゞ',
      'The power of procrastination is STRONG in this one... But you\'re stronger! Do "$taskTitle"! ヾ(≧▽≦*)o',
      '${urgent ? "⚠️ URGENT! " : ""}Senpai noticed "$taskTitle" is still pending... senpai is sad. (>_<)',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  // In-app pester for web: trigger immediately (for testing or immediate due tasks)
  void triggerImmediatePester(List<Task> pendingTasks) {
    if (pendingTasks.isNotEmpty) {
      _triggerPester(pendingTasks);
    }
  }

  // Schedule a one-time reminder (mobile-first, web shows in-app)
  Future<void> scheduleTaskReminder({
    required Task task,
    required DateTime when,
  }) async {
    if (kIsWeb) {
      // On web: set a timer for the delay
      final delay = when.difference(DateTime.now());
      if (delay.isNegative) return;
      Timer(delay, () => _triggerPester([task]));
    }
    // On mobile: real notifications would be scheduled here
    // Requires flutter_local_notifications integration
  }
}
