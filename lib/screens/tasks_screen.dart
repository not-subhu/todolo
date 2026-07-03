import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TasksProvider, AppProvider>(
      builder: (context, tasks, app, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Tasks',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KawaiiColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync, color: KawaiiColors.lavender),
                tooltip: 'Sync Todoist',
                onPressed: () => _syncTodoist(context, tasks, app),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: KawaiiColors.sakuraPink,
              indicatorWeight: 3,
              labelColor: KawaiiColors.sakuraPink,
              unselectedLabelColor: KawaiiColors.textMuted,
              labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Active (${tasks.pendingCount})'),
                const Tab(text: 'Overdue'),
                const Tab(text: 'Done'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(
                context,
                [
                  ...tasks.overdueTasks,
                  ...tasks.todayTasks,
                  ...tasks.upcomingTasks,
                  ...tasks.pendingTasks,
                ],
                tasks,
                app,
                emptyEmoji: '(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧',
                emptyTitle: 'All clear, senpai!',
                emptySubtitle:
                    'No pending tasks. Time to add more goals! (◕‿◕✿)',
              ),
              _buildTaskList(
                context,
                tasks.overdueTasks,
                tasks,
                app,
                emptyEmoji: '(✿◠‿◠)',
                emptyTitle: 'No overdue tasks!',
                emptySubtitle: 'You\'re on top of everything~ sugoi!',
              ),
              _buildTaskList(
                context,
                tasks.completedTasks,
                tasks,
                app,
                emptyEmoji: '(´・ω・`)',
                emptyTitle: 'Nothing completed yet',
                emptySubtitle: 'Start checking off tasks to fill this up!',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addTask(context, tasks, app),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Task',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: KawaiiColors.sakuraPink,
          ),
        );
      },
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Task> taskList,
    TasksProvider tasks,
    AppProvider app, {
    required String emptyEmoji,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (taskList.isEmpty) {
      return KawaiiEmptyState(
        emoji: emptyEmoji,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: taskList.length,
      itemBuilder: (ctx, i) => TaskCard(
        task: taskList[i],
        index: i,
        onComplete: taskList[i].status == TaskStatus.pending
            ? () => _completeTask(context, taskList[i].id, tasks, app)
            : null,
        onDelete: () => tasks.deleteTask(taskList[i].id),
        onTap: () => _editTask(context, taskList[i], tasks, app),
      ),
    );
  }

  void _addTask(BuildContext context, TasksProvider tasks, AppProvider app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          onTasksAdded: (newTasks) async {
            await tasks.addTasks(newTasks);
          },
          geminiKey: app.profile.geminiApiKey ?? '',
        ),
      ),
    );
  }

  void _editTask(
      BuildContext context, Task task, TasksProvider tasks, AppProvider app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          existingTask: task,
          onTasksAdded: (updated) async {
            if (updated.isNotEmpty) {
              await tasks.updateTask(updated.first);
            }
          },
          geminiKey: app.profile.geminiApiKey ?? '',
        ),
      ),
    );
  }

  Future<void> _completeTask(
    BuildContext context,
    String id,
    TasksProvider tasks,
    AppProvider app,
  ) async {
    final coins = await tasks.completeTask(id);
    await app.addCoins(coins);
    await app.incrementTasksCompleted();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🪙 +$coins coins earned! がんばった！',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          backgroundColor: KawaiiColors.sakuraPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _syncTodoist(
      BuildContext context, TasksProvider tasks, AppProvider app) async {
    final token = app.profile.todoistToken ?? '';
    if (token.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Add your Todoist token in Settings first! (˘ω˘)',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: KawaiiColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: KawaiiColors.sakuraPink),
        ),
      );
    }

    try {
      final added = await tasks.syncFromTodoist(token);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added > 0
                  ? '✨ Synced $added tasks from Todoist!'
                  : '(◕‿◕✿) Already up to date!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: KawaiiColors.lavender,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e', style: GoogleFonts.nunito()),
            backgroundColor: KawaiiColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
