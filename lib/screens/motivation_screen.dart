
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen>
    with SingleTickerProviderStateMixin {
  String? _caption;
  bool _isLoadingCaption = false;
  late AnimationController _pulseController;

  final List<String> _fallbackCaptions = [
    'You\'ve been working so hard... I\'m so proud of you! Every step matters, even the small ones~ (◕‿◕✿)',
    'Even the strongest hero needs rest. But then they get back up! That\'s you! ٩(◕‿◕)۶',
    'Your future self is watching you right now. Make them proud! You\'ve got this~ ✨',
    'Nee nee... you haven\'t given up yet. That makes you stronger than you know. (＾◡＾)✌️',
    'Senpai believes in you! The final boss is just another challenge you\'re ready to beat! ⭐',
    'I\'ve been watching your journey... and wow. You\'ve come so far. Don\'t stop now! 🌸',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadCaption();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCaption() async {
    final app = context.read<AppProvider>();
    final key = app.profile.geminiApiKey ?? '';
    final streak = app.profile.currentStreak;
    final username = app.profile.username;

    if (key.isEmpty) {
      setState(() {
        final idx = DateTime.now().second % _fallbackCaptions.length;
        _caption = _fallbackCaptions[idx];
      });
      return;
    }

    setState(() => _isLoadingCaption = true);
    try {
      final svc = GeminiService(key);
      final caption = await svc.generateMotivationCaption(username, streak);
      setState(() {
        _caption = caption;
        _isLoadingCaption = false;
      });
    } catch (_) {
      setState(() {
        final idx = DateTime.now().second % _fallbackCaptions.length;
        _caption = _fallbackCaptions[idx];
        _isLoadingCaption = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final profile = app.profile;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Motivation',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: KawaiiColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: KawaiiColors.lavender),
                onPressed: _loadCaption,
                tooltip: 'New message',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              children: [
                // Main mascot card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        KawaiiColors.sakuraPink.withAlpha(40),
                        KawaiiColors.lavender.withAlpha(30),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: KawaiiColors.sakuraPink.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Anime girl display
                      _buildMascotDisplay(),
                      const SizedBox(height: 20),

                      // Caption
                      if (_isLoadingCaption)
                        const CircularProgressIndicator(
                            color: KawaiiColors.sakuraPink)
                      else
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _caption ?? '',
                            key: ValueKey(_caption),
                            style: GoogleFonts.nunito(
                              color: KawaiiColors.textPrimary,
                              fontSize: 15,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 24),

                // Stats motivation
                _buildMotivationStats(profile),
                const SizedBox(height: 20),

                // Quote cards
                _buildPassingTimeWarning(profile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMascotDisplay() {
    // Try to show the AI-generated image if it exists
    final mascotPath = 'assets/images/motivation_girl.png';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (ctx, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.03),
          child: child,
        );
      },
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              KawaiiColors.sakuraPink.withAlpha(60),
              KawaiiColors.lavender.withAlpha(40),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: KawaiiColors.sakuraPink.withAlpha(60),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: !kIsWeb
              ? Image.asset(
                  mascotPath,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => _fallbackMascot(),
                )
              : _fallbackMascot(),
        ),
      ),
    );
  }

  Widget _fallbackMascot() {
    return Container(
      color: Colors.transparent,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(ﾉ≧∀≦)ﾉ', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text('＊☆∗・゜ﾟ・∗☆', style: TextStyle(fontSize: 16, color: KawaiiColors.sakuraPink)),
        ],
      ),
    );
  }

  Widget _buildMotivationStats(profile) {
    return Column(
      children: [
        Row(
          children: [
            _motivCard(
              '🔥 ${profile.currentStreak}',
              'Day Streak',
              profile.currentStreak >= 7
                  ? 'On fire!! (ﾉ≧∀≦)ﾉ'
                  : profile.currentStreak >= 3
                      ? 'Keep going! ٩(◕‿◕)۶'
                      : 'Start your streak~',
              KawaiiColors.gold,
            ),
            const SizedBox(width: 12),
            _motivCard(
              'Lv.${profile.level}',
              profile.levelTitle,
              '${profile.xpInLevel}/100 XP to next level',
              KawaiiColors.lavender,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _motivCard(
              '✅ ${profile.tasksCompleted}',
              'Tasks Done',
              'Every one counts! ✨',
              KawaiiColors.priorityLow,
            ),
            const SizedBox(width: 12),
            _motivCard(
              '🪙 ${profile.totalCoinsEarned}',
              'Total Earned',
              'Look at that grind! (◕‿◕✿)',
              KawaiiColors.sakuraPink,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _motivCard(String value, String label, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              sub,
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

  Widget _buildPassingTimeWarning(profile) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final percentYearGone = (dayOfYear / 365 * 100).toStringAsFixed(1);

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('⏳', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time is moving~',
                      style: GoogleFonts.nunito(
                        color: KawaiiColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '$percentYearGone% of this year has passed. (˘ω˘)',
                      style: GoogleFonts.nunito(
                        color: KawaiiColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: dayOfYear / 365,
            minHeight: 6,
            backgroundColor: KawaiiColors.cardMid,
            valueColor: AlwaysStoppedAnimation<Color>(
              dayOfYear / 365 > 0.7
                  ? KawaiiColors.priorityHigh
                  : KawaiiColors.lavender,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The best time to start was yesterday. The second best time is right now! ٩(◕‿◕)۶',
            style: GoogleFonts.nunito(
              color: KawaiiColors.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}
