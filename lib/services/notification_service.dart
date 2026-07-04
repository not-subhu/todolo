import 'dart:async';
import 'dart:math';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';

/// Manages the pestering system:
/// - On task add: generates 15 pester messages via Gemini, stores per-task
/// - Periodic timer picks a random message from all pending task pools
/// - On task complete: clears that task's pester pool
/// - Retry queue: if Gemini unavailable, stores request and retries every 5 min
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _pesterTimer;
  Timer? _retryTimer;
  final _db = DatabaseService();
  final _rng = Random();

  String _username = 'User';
  String? _geminiKey;
  String? _customPrompt;
  bool _enabled = true;
  int _intervalMinutes = 30;

  Function(String)? _onPester;

  // ── Configuration ─────────────────────────────────────────────────────────
  void configure({
    required String username,
    String? geminiKey,
    String? customPrompt,
    required bool pesteringEnabled,
    required int intervalMinutes,
    required Function(String) onPester,
  }) {
    _username = username;
    _geminiKey = geminiKey;
    _customPrompt = customPrompt;
    _enabled = pesteringEnabled;
    _intervalMinutes = intervalMinutes;
    _onPester = onPester;

    _pesterTimer?.cancel();
    _retryTimer?.cancel();

    if (_enabled) {
      _pesterTimer = Timer.periodic(
        Duration(minutes: _intervalMinutes),
        (_) => _tick(),
      );
    }

    // Retry queue fires every 5 minutes regardless
    _retryTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _processRetryQueue(),
    );
  }

  void stopAll() {
    _pesterTimer?.cancel();
    _retryTimer?.cancel();
    _pesterTimer = null;
    _retryTimer = null;
  }

  // ── On task added: generate pester batch ─────────────────────────────────
  /// Called after a new task is saved. Returns whether generation succeeded.
  Future<bool> generatePesterBatchForTask(Task task) async {
    if (_geminiKey == null || _geminiKey!.isEmpty) return false;
    try {
      final svc = GeminiService(_geminiKey!);
      final messages = await svc.generatePesterBatch(
        taskTitle: task.title,
        username: _username,
        customPrompt: _customPrompt,
      );
      await _db.savePesterMessages(task.id, messages);
      return true;
    } catch (e) {
      if (isBothModelsUnavailable(e)) {
        await _queueRetry(task);
      }
      return false;
    }
  }

  // ── On task complete: clear its pester pool ───────────────────────────────
  Future<void> clearPesterForTask(String taskId) async {
    await _db.deletePesterMessages(taskId);
  }

  // ── Periodic tick: pick random message ───────────────────────────────────
  Future<void> _tick() async {
    if (!_enabled) return;
    final tasks = await _db.getTasks();
    final pending = tasks.where((t) => t.status == TaskStatus.pending).toList();
    if (pending.isEmpty) return;

    // Build pool: collect all messages from all pending tasks
    final pool = <_PesterEntry>[];
    for (final task in pending) {
      final msgs = await _db.getPesterMessages(task.id);
      for (final msg in msgs) {
        pool.add(_PesterEntry(taskId: task.id, message: msg));
      }
    }

    if (pool.isEmpty) {
      // Fallback: use a hardcoded message for a random pending task
      final task = pending[_rng.nextInt(pending.length)];
      _firePester(_hardcodedFallback(task.title));
      return;
    }

    final pick = pool[_rng.nextInt(pool.length)];
    _firePester(pick.message);
  }

  void _firePester(String message) {
    _onPester?.call(message);
  }

  // ── Retry queue ───────────────────────────────────────────────────────────
  Future<void> _queueRetry(Task task) async {
    final pending = await _db.getPendingAi();
    // Avoid duplicates
    if (pending.any((e) => e['taskId'] == task.id)) return;
    pending.add({
      'taskId': task.id,
      'taskTitle': task.title,
      'queuedAt': DateTime.now().toIso8601String(),
    });
    await _db.savePendingAi(pending);
  }

  Future<void> _processRetryQueue() async {
    if (_geminiKey == null || _geminiKey!.isEmpty) return;
    final pending = await _db.getPendingAi();
    if (pending.isEmpty) return;

    final svc = GeminiService(_geminiKey!);
    final remaining = <Map<String, dynamic>>[];

    for (final entry in pending) {
      // Only retry if task still exists and is pending
      final tasks = await _db.getTasks();
      final task = tasks.where((t) => t.id == entry['taskId']).firstOrNull;
      if (task == null || task.status != TaskStatus.pending) continue;

      try {
        final messages = await svc.generatePesterBatch(
          taskTitle: entry['taskTitle'] ?? task.title,
          username: _username,
          customPrompt: _customPrompt,
        );
        await _db.savePesterMessages(task.id, messages);
        _onRetrySuccess?.call(task.title);
      } catch (_) {
        remaining.add(entry); // still unavailable, keep in queue
      }
    }

    await _db.savePendingAi(remaining);
  }

  /// Callback when a queued task's pester messages are finally generated
  Function(String taskTitle)? _onRetrySuccess;
  void setRetrySuccessCallback(Function(String) cb) => _onRetrySuccess = cb;

  String _hardcodedFallback(String taskTitle) {
    final msgs = [
      'Hey... "$taskTitle" is still there. Just sitting. Judging you. (｡•́︿•̀｡)',
      'NANI?! "$taskTitle" remains untouched?! The audacity! ٩(ఠ益ఠ)۶',
      'Your task "$taskTitle" misses you. In a very passive-aggressive way. (；´д｀)ゞ',
      '"$taskTitle" is growing sentient from being ignored this long. Do it. Now. ┐(￣ヘ￣)┌',
    ];
    return msgs[_rng.nextInt(msgs.length)];
  }

  /// Manually trigger a pester (for testing)
  Future<void> triggerTest(List<Task> tasks) async {
    if (tasks.isNotEmpty) await _tick();
  }
}

class _PesterEntry {
  final String taskId;
  final String message;
  const _PesterEntry({required this.taskId, required this.message});
}
