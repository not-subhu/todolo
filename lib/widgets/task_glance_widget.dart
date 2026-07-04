/// "At a Glance" — 2×2 home-screen liquid-glass widget.
///
/// Shows either the highest-priority pending task or the earliest-added
/// pending task, cycling every 8 seconds.  Has a quick-add "+" button.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import 'glass_widget_shell.dart';

class TaskGlanceWidget extends StatefulWidget {
  final VoidCallback onAddTask;

  const TaskGlanceWidget({super.key, required this.onAddTask});

  @override
  State<TaskGlanceWidget> createState() => _TaskGlanceWidgetState();
}

class _TaskGlanceWidgetState extends State<TaskGlanceWidget>
    with SingleTickerProviderStateMixin {
  /// When true, displays the earliest-created task instead of top-priority.
  bool _showFirstAdded = false;
  Timer? _cycleTimer;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _cycleTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted) return;
      await _fadeCtrl.reverse();
      if (mounted) setState(() => _showFirstAdded = !_showFirstAdded);
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Task selection ─────────────────────────────────────────────────────────
  Task? _pick(List<Task> pending) {
    if (pending.isEmpty) return null;
    if (_showFirstAdded) {
      return (List<Task>.from(pending)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
          .first;
    }
    const order = [
      TaskPriority.urgent,
      TaskPriority.high,
      TaskPriority.medium,
      TaskPriority.low,
    ];
    for (final p in order) {
      final bucket = pending.where((t) => t.priority == p).toList()
        ..sort((a, b) {
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          if (a.dueDate != null) return -1;
          if (b.dueDate != null) return 1;
          return a.createdAt.compareTo(b.createdAt);
        });
      if (bucket.isNotEmpty) return bucket.first;
    }
    return null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tasksP = context.watch<TasksProvider>();
    final pending =
        tasksP.tasks.where((t) => t.status == TaskStatus.pending).toList();
    final task = _pick(pending);

    return GlassWidgetShell(
      glassLevel: app.glassLevel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                _showFirstAdded
                    ? Icons.history_rounded
                    : Icons.bolt_rounded,
                color: ScreechColors.primaryLit,
                size: 13,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _showFirstAdded ? 'First Added' : 'Top Priority',
                  style: GoogleFonts.inter(
                    color: ScreechColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              // Cycle indicator dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [false, true].map((v) {
                  final active = _showFirstAdded == v;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: active ? 12 : 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? ScreechColors.primaryLit
                          : ScreechColors.textMuted.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 6),
              // Quick-add button
              GestureDetector(
                onTap: widget.onAddTask,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ScreechColors.primary.withAlpha(55),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: ScreechColors.primary.withAlpha(90), width: 0.8),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: ScreechColors.primaryLit, size: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: task == null ? _buildEmpty() : _buildTask(task, pending.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            'All clear!',
            style: GoogleFonts.inter(
              color: ScreechColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Add a task',
            style: GoogleFonts.inter(
              color: ScreechColors.textMuted.withAlpha(140),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTask(Task task, int total) {
    final prioColor = AppTheme.priorityColor(task.priority.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority badge
        _PriorityPill(priority: task.priority, color: prioColor),
        const SizedBox(height: 7),
        // Title — main content
        Expanded(
          child: Text(
            task.title,
            style: GoogleFonts.inter(
              color: ScreechColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Footer: due date + total
        Row(
          children: [
            if (task.dueDate != null) ...[
              Icon(
                Icons.schedule_rounded,
                size: 9,
                color: task.isOverdue
                    ? ScreechColors.danger
                    : ScreechColors.textMuted,
              ),
              const SizedBox(width: 3),
              Text(
                _fmtDate(task.dueDate!),
                style: GoogleFonts.inter(
                  color: task.isOverdue
                      ? ScreechColors.danger
                      : ScreechColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
            ] else
              const Spacer(),
            // Pending count chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ScreechColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '$total left',
                style: GoogleFonts.inter(
                  color: ScreechColors.primaryLit,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return '${diff.abs()}d ago';
    if (diff < 7) return DateFormat('EEE').format(d);
    return DateFormat('MMM d').format(d);
  }
}

// ── Priority pill ──────────────────────────────────────────────────────────
class _PriorityPill extends StatelessWidget {
  final TaskPriority priority;
  final Color color;
  const _PriorityPill({required this.priority, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      TaskPriority.urgent => 'URGENT',
      TaskPriority.high   => 'HIGH',
      TaskPriority.medium => 'MED',
      TaskPriority.low    => 'LOW',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withAlpha(60), width: 0.7),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
