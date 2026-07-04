/// "All Tasks" — 3×2 home-screen liquid-glass widget.
///
/// Shows all pending tasks sorted by priority in a scrollable plain-text list.
/// Scrolling inside the widget reveals additional tasks.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import 'glass_widget_shell.dart';

class TaskListWidget extends StatelessWidget {
  final VoidCallback onAddTask;

  const TaskListWidget({super.key, required this.onAddTask});

  // ── Sorted pending tasks (urgent → high → medium → low → oldest) ──────────
  List<Task> _sorted(List<Task> all) {
    const order = [
      TaskPriority.urgent,
      TaskPriority.high,
      TaskPriority.medium,
      TaskPriority.low,
    ];
    return (all.where((t) => t.status == TaskStatus.pending).toList())
      ..sort((a, b) {
        final byPrio =
            order.indexOf(a.priority).compareTo(order.indexOf(b.priority));
        if (byPrio != 0) return byPrio;
        return a.createdAt.compareTo(b.createdAt);
      });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tasksP = context.watch<TasksProvider>();
    final pending = _sorted(tasksP.tasks);

    return GlassWidgetShell(
      glassLevel: app.glassLevel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.format_list_bulleted_rounded,
                  color: ScreechColors.primaryLit, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'All Tasks',
                  style: GoogleFonts.inter(
                    color: ScreechColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (pending.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ScreechColors.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${pending.length}',
                    style: GoogleFonts.inter(
                      color: ScreechColors.primaryLit,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              // Quick-add button
              GestureDetector(
                onTap: onAddTask,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: ScreechColors.primary.withAlpha(55),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: ScreechColors.primary.withAlpha(90), width: 0.8),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: ScreechColors.primaryLit, size: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Divider ───────────────────────────────────────────────────────
          Container(
            height: 0.5,
            color: Colors.white.withAlpha(18),
          ),

          const SizedBox(height: 6),

          // ── Scrollable list ───────────────────────────────────────────────
          Expanded(
            child: pending.isEmpty
                ? _buildEmpty()
                : NotificationListener<ScrollNotification>(
                    // Prevent inner scroll from bubbling to home scroll
                    onNotification: (n) => true,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: pending.length,
                      itemBuilder: (ctx, i) =>
                          _TaskRow(task: pending[i], isLast: i == pending.length - 1),
                    ),
                  ),
          ),

          // ── Scroll hint (only when more than ~4 visible) ──────────────────
          if (pending.length > 4)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 10,
                        color: ScreechColors.textMuted.withAlpha(120)),
                    Text(
                      'scroll for more',
                      style: GoogleFonts.inter(
                        color: ScreechColors.textMuted.withAlpha(120),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
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
          const Text('✅', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Nothing pending',
            style: GoogleFonts.inter(
              color: ScreechColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Compact task row ───────────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final Task task;
  final bool isLast;
  const _TaskRow({required this.task, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final prioColor = AppTheme.priorityColor(task.priority.name);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Priority dot
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: prioColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.inter(
                    color: task.isOverdue
                        ? ScreechColors.danger
                        : ScreechColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Overdue micro-badge
              if (task.isOverdue) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: ScreechColors.danger.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '!',
                    style: GoogleFonts.inter(
                      color: ScreechColors.danger,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isLast)
          Container(height: 0.5, color: Colors.white.withAlpha(10)),
      ],
    );
  }
}
