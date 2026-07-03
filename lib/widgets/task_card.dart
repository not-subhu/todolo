import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'kawaii_widgets.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.low:
        return KawaiiColors.priorityLow;
      case TaskPriority.medium:
        return KawaiiColors.lavender;
      case TaskPriority.high:
        return KawaiiColors.priorityHigh;
      case TaskPriority.urgent:
        return KawaiiColors.priorityUrgent;
    }
  }

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Mid';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return '!!!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [KawaiiColors.cardDark, KawaiiColors.cardMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? KawaiiColors.priorityLow.withAlpha(60)
                  : _priorityColor.withAlpha(40),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: isCompleted ? null : onComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? KawaiiColors.sakuraPink
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? KawaiiColors.sakuraPink
                          : _priorityColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.nunito(
                        color: isCompleted
                            ? KawaiiColors.textMuted
                            : KawaiiColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: KawaiiColors.textMuted,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: KawaiiColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        PriorityBadge(
                          label: _priorityLabel,
                          color: _priorityColor,
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: task.isOverdue
                                ? KawaiiColors.priorityHigh
                                : KawaiiColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatDue(task.dueDate!),
                            style: GoogleFonts.nunito(
                              color: task.isOverdue
                                  ? KawaiiColors.priorityHigh
                                  : KawaiiColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Coin reward
              Column(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  Text(
                    '+${task.coinReward}',
                    style: GoogleFonts.nunito(
                      color: isCompleted
                          ? KawaiiColors.textMuted
                          : KawaiiColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 60))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  String _formatDue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}
