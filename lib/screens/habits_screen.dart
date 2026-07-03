import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/app_provider.dart';
import '../providers/habits_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/kawaii_widgets.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitsProvider, AppProvider>(
      builder: (context, habits, app, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Habits',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KawaiiColors.textPrimary,
              ),
            ),
          ),
          body: habits.habits.isEmpty
              ? KawaiiEmptyState(
                  emoji: '🌸',
                  title: 'No habits yet!',
                  subtitle:
                      'Build your routine~ Small daily actions make a big difference! (◕‿◕✿)',
                  onAction: () => _showAddHabit(context, habits),
                  actionLabel: 'Add first habit!',
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          children: [
                            // Stats row
                            Row(
                              children: [
                                _summaryCard(
                                  '${habits.completedTodayCount}/${habits.habits.length}',
                                  'Done today',
                                  '✅',
                                ),
                                const SizedBox(width: 10),
                                _summaryCard(
                                  '${habits.totalStreak}',
                                  'Total streak',
                                  '🔥',
                                ),
                                const SizedBox(width: 10),
                                _summaryCard(
                                  '${habits.habits.length}',
                                  'Active habits',
                                  '🌸',
                                ),
                              ],
                            ).animate().fadeIn(duration: 400.ms),
                            const SizedBox(height: 16),
                            const SectionHeader(
                              title: 'Today\'s Check-ins',
                              subtitle: 'Tap "Done!" to check in and earn coins',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final habit = habits.habits[i];
                            return HabitCard(
                              habit: habit,
                              index: i,
                              onCheckIn: () =>
                                  _checkIn(context, habit.id, habits, app),
                              onDelete: () => habits.deleteHabit(habit.id),
                              onTap: () => _editHabit(context, habit, habits),
                            );
                          },
                          childCount: habits.habits.length,
                        ),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddHabit(context, habits),
            icon: const Icon(Icons.add),
            label: Text(
              'New Habit',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: KawaiiColors.sakuraPink,
          ),
        );
      },
    );
  }

  Widget _summaryCard(String value, String label, String emoji) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkIn(
    BuildContext context,
    String id,
    HabitsProvider habits,
    AppProvider app,
  ) async {
    final coins = await habits.checkInHabit(id);
    if (coins > 0) {
      await app.addCoins(coins);
      await app.incrementHabitsCompleted();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔥 Streak extended! +$coins coins! ٩(◕‿◕)۶',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: KawaiiColors.sakuraPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showAddHabit(BuildContext context, HabitsProvider habits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KawaiiColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddHabitSheet(habits: habits),
    );
  }

  void _editHabit(BuildContext context, Habit habit, HabitsProvider habits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KawaiiColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddHabitSheet(habits: habits, existing: habit),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final HabitsProvider habits;
  final Habit? existing;

  const _AddHabitSheet({required this.habits, this.existing});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  HabitCategory _category = HabitCategory.study;
  HabitFrequency _frequency = HabitFrequency.daily;
  int _coins = 15;
  String _emoji = '⭐';

  final List<String> _emojis = ['⭐', '📚', '💪', '🧘', '🌱', '🎨', '💧', '🏃', '🎵', '✍️'];
  final List<String> _categoryLabels = ['Health', 'Study', 'Fitness', 'Mindfulness', 'Social', 'Creative', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final h = widget.existing!;
      _nameCtrl.text = h.name;
      _descCtrl.text = h.description;
      _category = h.category;
      _frequency = h.frequency;
      _coins = h.coinReward;
      _emoji = h.emoji;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KawaiiColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEditing ? 'Edit Habit' : 'New Habit~ (ﾉ◕ヮ◕)ﾉ',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Emoji picker
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => setState(() => _emoji = _emojis[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _emoji == _emojis[i]
                        ? KawaiiColors.sakuraPink
                        : KawaiiColors.cardMid,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(_emojis[i], style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: KawaiiColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Habit name'),
          ),
          const SizedBox(height: 12),

          // Category chips
          Wrap(
            spacing: 8,
            children: HabitCategory.values.asMap().entries.map((e) {
              return ChoiceChip(
                label: Text(_categoryLabels[e.key]),
                selected: _category == e.value,
                selectedColor: KawaiiColors.sakuraPink.withAlpha(60),
                onSelected: (_) => setState(() => _category = e.value),
                labelStyle: GoogleFonts.nunito(
                  color: _category == e.value
                      ? KawaiiColors.sakuraPink
                      : KawaiiColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Coin reward
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Coin reward: $_coins',
                style: GoogleFonts.nunito(color: KawaiiColors.textPrimary),
              ),
              Expanded(
                child: Slider(
                  value: _coins.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: KawaiiColors.sakuraPink,
                  onChanged: (v) => setState(() => _coins = v.toInt()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Habit!'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final habit = Habit(
      id: widget.existing?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      frequency: _frequency,
      coinReward: _coins,
      emoji: _emoji,
      completionDates: widget.existing?.completionDates,
    );
    if (widget.existing != null) {
      await widget.habits.updateHabit(habit);
    } else {
      await widget.habits.addHabit(habit);
    }
    if (mounted) Navigator.pop(context);
  }
}
