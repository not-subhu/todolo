import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/habits_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/side_panel.dart';
import '../widgets/task_glance_widget.dart';
import '../widgets/task_list_widget.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _expanded = false;
  int _quoteIdx = 0;
  Timer? _quoteTimer;

  static const double _headerH = 240.0;
  static const double _expandThreshold = 70.0;

  static const _quotes = [
    'Discipline today, freedom tomorrow.',
    'Small steps every single day.',
    'The grind never stops.',
    'Your future self is watching.',
    'Done is better than perfect.',
    'One task at a time.',
    'Make it happen. Now.',
    'Push through. Always.',
  ];

  @override
  void initState() {
    super.initState();
    _quoteIdx = DateTime.now().hour % _quotes.length;
    _scrollCtrl.addListener(_onScroll);
    _quoteTimer = Timer.periodic(const Duration(seconds: 22), (_) {
      if (mounted) setState(() => _quoteIdx = (_quoteIdx + 1) % _quotes.length);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final should = _scrollCtrl.offset > _expandThreshold;
    if (should != _expanded) setState(() => _expanded = should);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;

    return Consumer3<AppProvider, TasksProvider, HabitsProvider>(
      builder: (context, app, tasks, habits, _) {
        final profile = app.profile;
        final pendingTasks = tasks.tasks
            .where((t) => t.status == TaskStatus.pending)
            .toList();
        final allHabits = habits.habits;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ScreechColors.bg,
          drawer: SidePanel(profile: profile),
          drawerScrimColor: Colors.black.withAlpha(160),
          body: Stack(
            children: [
              // ── Fixed header image ─────────────────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                height: _headerH + topPad,
                child: _buildHeader(profile, topPad),
              ),

              // ── Scrollable panel ───────────────────────────────────────
              CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Spacer pushes list below header
                  SliverToBoxAdapter(
                    child: SizedBox(height: _headerH + topPad - 28),
                  ),
                  // Pinned panel handle with rounded corners
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PanelHandleDelegate(
                      taskCount: pendingTasks.length,
                      habitCount: allHabits.length,
                    ),
                  ),
                  // ── Home-screen widget grid ────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: _buildWidgetGrid(context, app, tasks),
                    ),
                  ),

                  // Tasks section
                  if (pendingTasks.isEmpty && allHabits.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty())
                  else ...[
                    if (pendingTasks.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                        sliver: SliverToBoxAdapter(
                          child: _sectionLabel('Tasks', pendingTasks.length),
                        ),
                      ),
                      SliverList.builder(
                        itemCount: pendingTasks.length,
                        itemBuilder: (ctx, i) => _buildTaskItem(
                          ctx, pendingTasks[i], app, tasks, i,
                        ),
                      ),
                    ],
                    if (allHabits.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                        sliver: SliverToBoxAdapter(
                          child: _sectionLabel('Habits', allHabits.length),
                        ),
                      ),
                      SliverList.builder(
                        itemCount: allHabits.length,
                        itemBuilder: (ctx, i) => _buildHabitItem(
                          ctx, allHabits[i], habits, app, i,
                        ),
                      ),
                    ],
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),

              // ── Fixed overlay buttons (hamburger + coin) ───────────────
              Positioned(
                top: topPad + 4,
                left: 4,
                right: 4,
                child: _buildTopBar(app),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(profile, double topPad) {
    final imgPath = profile.headerImagePath ?? 'assets/images/motivation_girl.png';
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          imgPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A3C), ScreechColors.bg],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Gradient fade at bottom so panel blends in
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x00000000),
                Color(0x00000000),
                Color(0xCC0A0812),
                Color(0xFF0A0812),
              ],
              stops: [0, 0.15, 0.45, 0.82, 1.0],
            ),
          ),
        ),
        // Motivational text
        Positioned(
          left: 20,
          right: 20,
          bottom: 40,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: Text(
              profile.motivationQuote ?? _quotes[_quoteIdx],
              key: ValueKey(_quoteIdx),
              style: GoogleFonts.inter(
                color: Colors.white.withAlpha(200),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Home-screen widget grid ───────────────────────────────────────────────
  /// Grid units: each unit ≈ 82 logical pixels tall.
  /// At-a-glance: 2 tall × 2 wide  →  164 px  (left half)
  /// All-tasks:   3 tall × 2 wide  →  246 px  (right half)
  Widget _buildWidgetGrid(
      BuildContext context, AppProvider app, TasksProvider tasksP) {
    void openAdd() {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddTaskScreen(
          geminiKey: app.profile.geminiApiKey ?? '',
          onTasksAdded: (newTasks) async => tasksP.addTasks(newTasks),
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ));
    }

    const unitH = 82.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 2×2: At a Glance ────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: unitH * 2, // 164 px
            child: TaskGlanceWidget(onAddTask: openAdd),
          ),
        ),
        const SizedBox(width: 10),
        // ── 3×2: All Tasks ───────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: unitH * 3, // 246 px
            child: TaskListWidget(onAddTask: openAdd),
          ),
        ),
      ],
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(AppProvider app) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Hamburger — uses GlobalKey so context is always valid
        _topButton(
          Icons.menu_rounded,
          () => _scaffoldKey.currentState?.openDrawer(),
        ),
        // Logo centre
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/screech_logo.png',
            width: 36, height: 36, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.pets_rounded,
              color: ScreechColors.primaryLit,
            ),
          ),
        ),
        // Coin display
        _coinBadge(app.profile.availableCoins),
      ],
    );
  }

  Widget _topButton(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _coinBadge(int coins) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(80),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x40F59E0B)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.toll_rounded, color: Color(0xFFF59E0B), size: 14),
            const SizedBox(width: 4),
            Text(
              '$coins',
              style: GoogleFonts.inter(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, int count) => Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: ScreechColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: ScreechColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.inter(
                color: ScreechColors.primaryLit,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );

  // ── Task item ─────────────────────────────────────────────────────────────
  Widget _buildTaskItem(
    BuildContext ctx,
    Task task,
    AppProvider app,
    TasksProvider tasksP,
    int index,
  ) {
    final prioColor = AppTheme.priorityColor(task.priority.name);
    final isOverdue = task.isOverdue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isOverdue
              ? const Color(0xFF1A0808)
              : ScreechColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverdue
                ? ScreechColors.danger.withAlpha(60)
                : ScreechColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Compact row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Priority indicator
                  Container(
                    width: 5, height: 36,
                    decoration: BoxDecoration(
                      color: prioColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Task icon
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: prioColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _taskIcon(task),
                      color: prioColor,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.inter(
                            color: ScreechColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: prioColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.priority.name,
                              style: GoogleFonts.inter(
                                color: prioColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              _fmtDate(task.dueDate!),
                              style: GoogleFonts.inter(
                                color: isOverdue
                                    ? ScreechColors.danger
                                    : ScreechColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  // Coin reward
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.toll_rounded,
                            color: Color(0xFFF59E0B), size: 13),
                        const SizedBox(width: 2),
                        Text(
                          '${task.coinReward}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      // Complete checkbox
                      GestureDetector(
                        onTap: () => _completeTask(ctx, task.id, app, tasksP),
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ScreechColors.textMuted, width: 1.5),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Expanded section ───────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) ...[
                          Divider(
                              color: ScreechColors.glassBorder,
                              height: 1,
                              indent: 14,
                              endIndent: 14),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: Text(
                              task.description,
                              style: GoogleFonts.inter(
                                color: ScreechColors.textSecondary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                          child: Row(children: [
                            _actionChip(
                              'Complete',
                              ScreechColors.primary,
                              () => _completeTask(
                                  ctx, task.id, app, tasksP),
                            ),
                            const SizedBox(width: 8),
                            _actionChip(
                              'Delete',
                              ScreechColors.danger.withAlpha(40),
                              () => tasksP.deleteTask(task.id),
                              textColor: ScreechColors.danger,
                            ),
                          ]),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }

  // ── Habit item ────────────────────────────────────────────────────────────
  Widget _buildHabitItem(
    BuildContext ctx,
    Habit habit,
    HabitsProvider habitsP,
    AppProvider app,
    int index,
  ) {
    final done = habit.isCompletedToday;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFF081A0D)
              : ScreechColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? ScreechColors.success.withAlpha(50)
                : ScreechColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Compact row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Emoji avatar
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: ScreechColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(habit.emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: GoogleFonts.inter(
                            color: ScreechColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: ScreechColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Habit · ${habit.frequency.name}',
                              style: GoogleFonts.inter(
                                color: ScreechColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  // Streak + check-in
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 2),
                        Text(
                          '${habit.currentStreak}',
                          style: GoogleFonts.inter(
                            color: ScreechColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: done
                            ? null
                            : () =>
                                _checkIn(ctx, habit.id, habitsP, app),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: done
                                ? ScreechColors.success
                                : Colors.transparent,
                            border: Border.all(
                              color: done
                                  ? ScreechColors.success
                                  : ScreechColors.textMuted,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: done
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Expanded: 7-day grid ────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                            color: ScreechColors.glassBorder,
                            height: 1,
                            indent: 14,
                            endIndent: 14),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14, 10, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last 7 days',
                                style: GoogleFonts.inter(
                                  color: ScreechColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _sevenDayGrid(habit),
                              if (!done) ...[
                                const SizedBox(height: 10),
                                _actionChip(
                                  'Check in today',
                                  ScreechColors.success.withAlpha(40),
                                  () => _checkIn(
                                      ctx, habit.id, habitsP, app),
                                  textColor: ScreechColors.success,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _sevenDayGrid(Habit habit) {
    final today = DateTime.now();
    return Row(
      children: List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        final dateOnly = DateTime(day.year, day.month, day.day);
        final completed = habit.completionDates.any((d) =>
            DateTime(d.year, d.month, d.day) == dateOnly);
        return Expanded(
          child: Column(children: [
            Text(
              DateFormat('E').format(day).substring(0, 1),
              style: GoogleFonts.inter(
                  color: ScreechColors.textMuted, fontSize: 9),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: completed
                    ? ScreechColors.success.withAlpha(80)
                    : ScreechColors.bgPanel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: completed
                      ? ScreechColors.success.withAlpha(100)
                      : ScreechColors.glassBorder,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check_rounded,
                      color: ScreechColors.success, size: 14)
                  : null,
            ),
          ]),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('(◕‿◕✿)',
              style: TextStyle(
                  fontSize: 40, color: ScreechColors.textMuted)),
          const SizedBox(height: 12),
          Text(
            'Nothing here yet.',
            style: GoogleFonts.inter(
              color: ScreechColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            'Add a task to get started — the pester system is waiting.',
            style: GoogleFonts.inter(
                color: ScreechColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _actionChip(
    String label,
    Color bg,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  IconData _taskIcon(Task task) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return Icons.warning_amber_rounded;
      case TaskPriority.high:
        return Icons.priority_high_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(d.year, d.month, d.day);
    final diff = taskDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff < -1) return '${diff.abs()}d overdue';
    if (diff < 7) return DateFormat('EEE').format(d);
    return DateFormat('MMM d').format(d);
  }

  Future<void> _completeTask(
    BuildContext ctx,
    String id,
    AppProvider app,
    TasksProvider tasksP,
  ) async {
    final coins = await tasksP.completeTask(id);
    await app.addCoins(coins);
    await app.incrementTasksCompleted();
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('+$coins coins earned!',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: ScreechColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _checkIn(
    BuildContext ctx,
    String id,
    HabitsProvider habitsP,
    AppProvider app,
  ) async {
    final coins = await habitsP.checkInHabit(id);
    if (coins > 0) {
      await app.addCoins(coins);
      await app.incrementHabitsCompleted();
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Habit done! +$coins coins',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: ScreechColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }
}

// ── Sliver panel handle delegate ──────────────────────────────────────────
class _PanelHandleDelegate extends SliverPersistentHeaderDelegate {
  final int taskCount;
  final int habitCount;

  const _PanelHandleDelegate({
    required this.taskCount,
    required this.habitCount,
  });

  @override
  double get minExtent => 58;
  @override
  double get maxExtent => 58;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: ScreechColors.bg,
        borderRadius: overlapsContent
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!overlapsContent)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ScreechColors.textMuted.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Today',
                    style: GoogleFonts.inter(
                      color: ScreechColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ScreechColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$taskCount tasks · $habitCount habits',
                      style: GoogleFonts.inter(
                        color: ScreechColors.primaryLit,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  bool shouldRebuild(covariant _PanelHandleDelegate old) =>
      old.taskCount != taskCount || old.habitCount != habitCount;
}
