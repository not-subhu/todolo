import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/habits_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _streakTimer;
  final List<String> _quotes = [
    'You\'ve got this, senpai! One task at a time~ (◕‿◕✿)',
    'Every completed task makes you stronger! ٩(◕‿◕)۶',
    'Your future self is cheering for you right now! ✨',
    'Small steps still move you forward! がんばって！',
    'The protagonist never gives up. Neither do you! (ﾉ≧∀≦)ﾉ',
    'Level up your life, one task at a time! ⭐',
    'You\'re not procrastinating... you\'re preparing! (¬‿¬)',
    'Believe in the you that believes in completing tasks! 💪',
  ];
  int _quoteIdx = 0;

  @override
  void initState() {
    super.initState();
    _quoteIdx = DateTime.now().hour % _quotes.length;
    _streakTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          setState(() {
            _quoteIdx = (_quoteIdx + 1) % _quotes.length;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _streakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppProvider, TasksProvider, HabitsProvider>(
      builder: (context, app, tasks, habits, _) {
        final profile = app.profile;
        final todayTasks = tasks.todayTasks;
        final overdueTasks = tasks.overdueTasks;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                floating: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: GoogleFonts.nunito(
                                  color: KawaiiColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                profile.username,
                                style: GoogleFonts.nunito(
                                  color: KawaiiColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _testPester(context, tasks),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: KawaiiColors.sakuraPink.withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text('🪙',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  '${profile.availableCoins}',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats row
                    _buildStatsRow(profile, tasks, habits),
                    const SizedBox(height: 20),

                    // Quote / mascot card
                    _buildMascotCard(),
                    const SizedBox(height: 20),

                    // Level progress
                    GlassCard(
                      child: LevelProgressBar(
                        level: profile.level,
                        progress: profile.levelProgress,
                        title: profile.levelTitle,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Overdue tasks
                    if (overdueTasks.isNotEmpty) ...[
                      const SectionHeader(
                        title: '⚠️ Overdue',
                        subtitle: 'These need attention NOW!',
                      ),
                      ...overdueTasks.take(3).toList().asMap().entries.map(
                            (e) => TaskCard(
                              task: e.value,
                              index: e.key,
                              onComplete: () =>
                                  _completeTask(context, e.value.id),
                              onDelete: () =>
                                  context.read<TasksProvider>().deleteTask(e.value.id),
                            ),
                          ),
                      const SizedBox(height: 8),
                    ],

                    // Today's tasks
                    SectionHeader(
                      title: '📅 Today',
                      subtitle: DateFormat('EEEE, MMM d').format(DateTime.now()),
                      trailing: Text(
                        '${todayTasks.length} left',
                        style: GoogleFonts.nunito(
                          color: KawaiiColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (todayTasks.isEmpty)
                      _buildEmptyToday()
                    else
                      ...todayTasks.take(5).toList().asMap().entries.map(
                            (e) => TaskCard(
                              task: e.value,
                              index: e.key,
                              onComplete: () =>
                                  _completeTask(context, e.value.id),
                              onDelete: () =>
                                  context.read<TasksProvider>().deleteTask(e.value.id),
                            ),
                          ),

                    const SizedBox(height: 20),

                    // Habit check-ins
                    const SectionHeader(
                      title: '🌸 Habits today',
                    ),
                    _buildHabitSummary(habits),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(profile, tasks, habits) {
    return Row(
      children: [
        _statCard('🔥', '${profile.currentStreak}', 'Day streak'),
        const SizedBox(width: 10),
        _statCard('✅', '${profile.tasksCompleted}', 'Completed'),
        const SizedBox(width: 10),
        _statCard('🌸', '${habits.completedTodayCount}/${habits.habits.length}', 'Habits'),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotCard() {
    return GlassCard(
      child: Row(
        children: [
          // Mascot image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KawaiiColors.sakuraPink.withAlpha(50),
                  KawaiiColors.lavender.withAlpha(50),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('(◕‿◕✿)', style: TextStyle(fontSize: 18, color: KawaiiColors.sakuraPink)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Text(
                _quotes[_quoteIdx],
                key: ValueKey(_quoteIdx),
                style: GoogleFonts.nunito(
                  color: KawaiiColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildEmptyToday() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('(✿◠‿◠)', style: TextStyle(fontSize: 32, color: KawaiiColors.sakuraPink)),
          const SizedBox(height: 8),
          Text(
            'No tasks due today!',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            'Either you\'re super ahead, or super in denial~ (¬‿¬)',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSummary(HabitsProvider habits) {
    if (habits.habits.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No habits yet! Add some to build your streak~ (◕‿◕✿)',
          style: GoogleFonts.nunito(color: KawaiiColors.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final pending = habits.pendingToday.take(3).toList();
    if (pending.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All habits done today! You\'re amazing! ٩(◕‿◕)۶',
                style: GoogleFonts.nunito(
                  color: KawaiiColors.priorityLow,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pending.map((h) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(h.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  h.name,
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _checkInHabit(context, h.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: KawaiiColors.sakuraPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Done!',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _testPester(BuildContext context, TasksProvider tasks) {
    final pending = tasks.tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList();
    NotificationService().triggerImmediatePester(pending);
  }

  Future<void> _completeTask(BuildContext context, String id) async {
    final appProvider = context.read<AppProvider>();
    final tasksProvider = context.read<TasksProvider>();
    final coins = await tasksProvider.completeTask(id);
    await appProvider.addCoins(coins);
    await appProvider.incrementTasksCompleted();
    if (context.mounted) {
      _showCoinEarned(context, coins);
    }
  }

  Future<void> _checkInHabit(BuildContext context, String id) async {
    final appProvider = context.read<AppProvider>();
    final habitsProvider = context.read<HabitsProvider>();
    final coins = await habitsProvider.checkInHabit(id);
    if (coins > 0) {
      await appProvider.addCoins(coins);
      await appProvider.incrementHabitsCompleted();
      if (context.mounted) {
        _showCoinEarned(context, coins);
      }
    }
  }

  void _showCoinEarned(BuildContext context, int coins) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '+$coins coins! Sugoi! ✨',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: KawaiiColors.sakuraPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Burning the midnight oil? 🌙';
    if (hour < 12) return 'Good morning~ ☀️';
    if (hour < 17) return 'Good afternoon~ 🌸';
    if (hour < 21) return 'Good evening~ 🌆';
    return 'Still up? 🌙';
  }
}
