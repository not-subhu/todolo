import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/motivation_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/kawaii_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameCtrl = TextEditingController();
  final _geminiCtrl = TextEditingController();
  final _todoistCtrl = TextEditingController();

  bool _showGeminiKey = false;
  bool _showTodoistToken = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().profile;
    _usernameCtrl.text = profile.username;
    _geminiCtrl.text = profile.geminiApiKey ?? '';
    _todoistCtrl.text = profile.todoistToken ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, app, _) {
        final profile = app.profile;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Profile & Settings',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: KawaiiColors.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile hero
                _buildProfileHero(profile).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 24),

                // Navigation
                const SectionHeader(title: '🌸 Sections'),
                _navCard(
                  icon: '(ﾉ≧∀≦)ﾉ',
                  title: 'Motivation Corner',
                  subtitle: 'Your anime senpai is cheering for you!',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MotivationScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _navCard(
                  icon: '🏆',
                  title: 'Leaderboard',
                  subtitle: 'See how you rank vs your friends!',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile settings
                const SectionHeader(title: '👤 Profile'),
                GlassCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameCtrl,
                        style: const TextStyle(color: KawaiiColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Your name / username',
                          prefixIcon:
                              Icon(Icons.person, color: KawaiiColors.lavender),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // API keys
                const SectionHeader(
                  title: '🔑 API Keys',
                  subtitle:
                      'Unlock AI features. Keys stay on your device only.',
                ),
                GlassCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _geminiCtrl,
                        obscureText: !_showGeminiKey,
                        style: const TextStyle(color: KawaiiColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Gemini API Key',
                          hintText: 'AIzaSy...',
                          prefixIcon:
                              const Icon(Icons.auto_awesome, color: KawaiiColors.lavender),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showGeminiKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: KawaiiColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _showGeminiKey = !_showGeminiKey),
                          ),
                          helperText:
                              'Get yours at aistudio.google.com — enables AI task parsing + smart notifications',
                          helperStyle: GoogleFonts.nunito(
                            color: KawaiiColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _todoistCtrl,
                        obscureText: !_showTodoistToken,
                        style: const TextStyle(color: KawaiiColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Todoist API Token',
                          prefixIcon: const Icon(Icons.sync, color: KawaiiColors.lavender),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showTodoistToken
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: KawaiiColors.textMuted,
                            ),
                            onPressed: () => setState(
                                () => _showTodoistToken = !_showTodoistToken),
                          ),
                          helperText:
                              'Get it from todoist.com/app/settings/integrations/developer',
                          helperStyle: GoogleFonts.nunito(
                            color: KawaiiColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Notification settings
                const SectionHeader(title: '🔔 Notifications'),
                GlassCard(
                  child: Column(
                    children: [
                      _switchRow(
                        'Pestering mode',
                        '(ﾉ≧∀≦)ﾉ Reminds you automatically!',
                        profile.pesteringEnabled,
                        (v) async {
                          profile.pesteringEnabled = v;
                          await app.updateProfile(profile);
                        },
                      ),
                      const Divider(color: KawaiiColors.cardMid),
                      _switchRow(
                        'Motivation reminders',
                        '(◕‿◕✿) Daily encouragement from senpai',
                        profile.motivationEnabled,
                        (v) async {
                          profile.motivationEnabled = v;
                          await app.updateProfile(profile);
                        },
                      ),
                      const Divider(color: KawaiiColors.cardMid),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pester interval',
                                  style: GoogleFonts.nunito(
                                    color: KawaiiColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Every ${profile.pesterIntervalMinutes} minutes',
                                  style: GoogleFonts.nunito(
                                    color: KawaiiColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: profile.pesterIntervalMinutes.toDouble(),
                            min: 5,
                            max: 120,
                            divisions: 23,
                            activeColor: KawaiiColors.sakuraPink,
                            onChanged: (v) async {
                              profile.pesterIntervalMinutes = v.toInt();
                              await app.updateProfile(profile);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(app),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save Settings~ ✨',
                      style:
                          GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHero(profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KawaiiColors.sakuraPink.withAlpha(40),
            KawaiiColors.lavender.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KawaiiColors.sakuraPink.withAlpha(60),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: KawaiiColors.sakuraPink.withAlpha(80),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : 'K',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Lv.${profile.level} ${profile.levelTitle}',
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.lavender,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                LevelProgressBar(
                  level: profile.level,
                  progress: profile.levelProgress,
                  title: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: KawaiiColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      color: KawaiiColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: KawaiiColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(
    String title,
    String subtitle,
    bool value,
    Future<void> Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  color: KawaiiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  color: KawaiiColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (v) => onChanged(v),
          activeColor: KawaiiColors.sakuraPink,
        ),
      ],
    );
  }

  Future<void> _save(AppProvider app) async {
    setState(() => _isSaving = true);
    final profile = app.profile;
    profile.username = _usernameCtrl.text.trim().isEmpty
        ? 'Student-chan'
        : _usernameCtrl.text.trim();
    profile.geminiApiKey =
        _geminiCtrl.text.trim().isEmpty ? null : _geminiCtrl.text.trim();
    profile.todoistToken =
        _todoistCtrl.text.trim().isEmpty ? null : _todoistCtrl.text.trim();
    await app.updateProfile(profile);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ Settings saved! Sugoi~ (◕‿◕✿)',
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
