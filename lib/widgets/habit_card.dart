import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onCheckIn;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const HabitCard({
    super.key,
    required this.habit,
    this.onCheckIn,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  Color get _categoryColor {
    switch (habit.category) {
      case HabitCategory.health:
        return KawaiiColors.priorityLow;
      case HabitCategory.study:
        return KawaiiColors.lavender;
      case HabitCategory.fitness:
        return KawaiiColors.coral;
      case HabitCategory.mindfulness:
        return KawaiiColors.teal;
      case HabitCategory.social:
        return KawaiiColors.lightPink;
      case HabitCategory.creative:
        return KawaiiColors.gold;
      case HabitCategory.other:
        return KawaiiColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = habit.isCompletedToday;

    return Dismissible(
      key: Key(habit.id),
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
              colors: completed
                  ? [
                      KawaiiColors.sakuraPink.withAlpha(30),
                      KawaiiColors.lavender.withAlpha(20),
                    ]
                  : [KawaiiColors.cardDark, KawaiiColors.cardMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed
                  ? KawaiiColors.sakuraPink.withAlpha(60)
                  : _categoryColor.withAlpha(40),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _categoryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    habit.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: GoogleFonts.nunito(
                        color: KawaiiColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: GoogleFonts.nunito(
                            color: habit.currentStreak > 0
                                ? KawaiiColors.gold
                                : KawaiiColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('🪙', style: TextStyle(fontSize: 12)),
                        Text(
                          '+${habit.coinReward}',
                          style: GoogleFonts.nunito(
                            color: KawaiiColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Check-in button
              GestureDetector(
                onTap: completed ? null : onCheckIn,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: completed
                        ? KawaiiColors.sakuraPink
                        : KawaiiColors.cardMid,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? KawaiiColors.sakuraPink
                          : KawaiiColors.lavender.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    completed ? Icons.check : Icons.add,
                    color: completed
                        ? Colors.white
                        : KawaiiColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 60))
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms),
      ),
    );
  }
}
