import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  final Future<void> Function(List<Task> tasks) onTasksAdded;
  final String geminiKey;

  const AddTaskScreen({
    super.key,
    this.existingTask,
    required this.onTasksAdded,
    this.geminiKey = '',
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Single task fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDayData? _dueTime;

  // AI parse fields
  final _aiTextCtrl = TextEditingController();
  List<Task> _parsedTasks = [];
  bool _isParsing = false;
  String? _parseError;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _isEditing ? 1 : 2,
      vsync: this,
    );
    if (_isEditing) {
      final t = widget.existingTask!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _priority = t.priority;
      _dueDate = t.dueDate;
      _dueTime = t.dueTime;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _aiTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KawaiiColors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEditing ? 'Edit Task' : 'Add Task',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: KawaiiColors.textPrimary,
          ),
        ),
        bottom: _isEditing
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: KawaiiColors.sakuraPink,
                labelColor: KawaiiColors.sakuraPink,
                unselectedLabelColor: KawaiiColors.textMuted,
                labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Manual'),
                  Tab(text: '✨ AI Parse'),
                ],
              ),
      ),
      body: _isEditing
          ? _buildManualForm()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildManualForm(),
                _buildAiParseForm(),
              ],
            ),
    );
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Task title',
              prefixIcon: Icon(Icons.task_alt, color: KawaiiColors.lavender),
            ),
            autofocus: !_isEditing,
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.notes, color: KawaiiColors.lavender),
            ),
          ),
          const SizedBox(height: 20),

          // Priority
          Text(
            'Priority',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final colors = {
                TaskPriority.low: KawaiiColors.priorityLow,
                TaskPriority.medium: KawaiiColors.lavender,
                TaskPriority.high: KawaiiColors.priorityHigh,
                TaskPriority.urgent: KawaiiColors.priorityUrgent,
              };
              final labels = {
                TaskPriority.low: 'Low',
                TaskPriority.medium: 'Medium',
                TaskPriority.high: 'High',
                TaskPriority.urgent: 'Urgent',
              };
              final c = colors[p]!;
              final selected = _priority == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? c.withAlpha(30) : KawaiiColors.cardMid,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? c : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      labels[p]!,
                      style: GoogleFonts.nunito(
                        color: selected ? c : KawaiiColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Due date
          Text(
            'Due Date',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: KawaiiColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dueDate != null
                            ? KawaiiColors.sakuraPink.withAlpha(80)
                            : KawaiiColors.lavender.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: KawaiiColors.lavender, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _dueDate != null
                              ? DateFormat('EEE, MMM d').format(_dueDate!)
                              : 'Set date',
                          style: GoogleFonts.nunito(
                            color: _dueDate != null
                                ? KawaiiColors.textPrimary
                                : KawaiiColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_dueDate != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  }),
                  child: const Icon(Icons.close, color: KawaiiColors.textMuted),
                ),
              ],
            ],
          ),
          if (_dueDate != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: KawaiiColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: KawaiiColors.lavender.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: KawaiiColors.lavender, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _dueTime?.toString() ?? 'Set time (optional)',
                      style: GoogleFonts.nunito(
                        color: _dueTime != null
                            ? KawaiiColors.textPrimary
                            : KawaiiColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveManual,
              child: Text(_isEditing ? 'Save Changes' : 'Add Task! ✨'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiParseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI Task Parser',
                        style: GoogleFonts.nunito(
                          color: KawaiiColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dump your thoughts below — Gemini will extract all the tasks for you! ٩(◕‿◕)۶',
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),

          if (widget.geminiKey.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KawaiiColors.coral.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KawaiiColors.coral.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: KawaiiColors.coral),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Add your Gemini API key in Settings to use AI parsing! (˘ω˘)',
                      style: GoogleFonts.nunito(
                        color: KawaiiColors.coral,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _aiTextCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary, height: 1.5),
            maxLines: 6,
            enabled: widget.geminiKey.isNotEmpty,
            decoration: InputDecoration(
              labelText: 'Yap away...',
              hintText:
                  'e.g. "I need to finish the math homework by friday, submit the english essay, review chapter 5 for the quiz on monday, and don\'t forget to email Prof. Tanaka about the lab report"',
              hintStyle: GoogleFonts.nunito(
                color: KawaiiColors.textMuted,
                fontSize: 13,
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          if (_parseError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _parseError!,
                style: GoogleFonts.nunito(color: KawaiiColors.coral, fontSize: 13),
              ),
            ),

          KawaiiButton(
            label: _isParsing ? 'Parsing...' : '✨ Parse with AI',
            onTap: _isParsing || widget.geminiKey.isEmpty ? null : _parseWithAi,
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 24),

          if (_parsedTasks.isNotEmpty) ...[
            const SectionHeader(
              title: 'Parsed Tasks',
              subtitle: 'Review and confirm!',
            ),
            ..._parsedTasks.asMap().entries.map((e) {
              final t = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _priorityColor(t.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: GoogleFonts.nunito(
                                color: KawaiiColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (t.description.isNotEmpty)
                              Text(
                                t.description,
                                style: GoogleFonts.nunito(
                                  color: KawaiiColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text('🪙 +${t.coinReward}',
                          style: GoogleFonts.nunito(
                            color: KawaiiColors.gold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: e.key * 100)).fadeIn().slideX();
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAllParsed,
                child: Text(
                  'Add ${_parsedTasks.length} tasks! ٩(◕‿◕)۶',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
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

  Future<void> _parseWithAi() async {
    final text = _aiTextCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
      _parseError = null;
      _parsedTasks = [];
    });

    try {
      final svc = GeminiService(widget.geminiKey);
      final parsed = await svc.parseTasksFromText(text);
      setState(() {
        _parsedTasks = parsed.map((p) => p.toTask()).toList();
      });
    } catch (e) {
      setState(() {
        _parseError = 'AI parsing failed: $e (check your API key)';
      });
    } finally {
      setState(() => _isParsing = false);
    }
  }

  Future<void> _saveManual() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final task = Task(
      id: widget.existingTask?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      dueTime: _dueTime,
    );
    await widget.onTasksAdded([task]);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveAllParsed() async {
    if (_parsedTasks.isEmpty) return;
    await widget.onTasksAdded(_parsedTasks);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: KawaiiColors.sakuraPink,
            surface: KawaiiColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _dueTime?.hour ?? 9,
        minute: _dueTime?.minute ?? 0,
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: KawaiiColors.sakuraPink,
            surface: KawaiiColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
          _dueTime = TimeOfDayData(hour: picked.hour, minute: picked.minute));
    }
  }
}
