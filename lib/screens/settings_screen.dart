import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
enum SettingsSection { main, keys }

class SettingsScreen extends StatefulWidget {
  final SettingsSection initialSection;
  const SettingsScreen({super.key, this.initialSection = SettingsSection.main});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameCtrl = TextEditingController();
  final _geminiCtrl = TextEditingController();
  final _todoistCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();

  bool _showGeminiKey = false;
  bool _showTodoistToken = false;
  bool _isSaving = false;
  bool _dangerExpanded = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().profile;
    _usernameCtrl.text = profile.username;
    _geminiCtrl.text = profile.geminiApiKey ?? '';
    _todoistCtrl.text = profile.todoistToken ?? '';
    _promptCtrl.text = profile.customPesterPrompt ?? '';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _geminiCtrl.dispose();
    _todoistCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeys = widget.initialSection == SettingsSection.keys;

    return Consumer<AppProvider>(
      builder: (ctx, app, _) {
        final profile = app.profile;
        return Scaffold(
          backgroundColor: ScreechColors.bg,
          appBar: AppBar(
            backgroundColor: ScreechColors.bg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: ScreechColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isKeys ? 'Keys' : 'Settings',
              style: GoogleFonts.inter(
                  color: ScreechColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile ────────────────────────────────────────────────
                if (!isKeys) ...[
                  _sectionLabel('Profile'),
                  _card(
                    child: Column(children: [
                      TextField(
                        controller: _usernameCtrl,
                        style: const TextStyle(color: ScreechColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: ScreechColors.textMuted),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // ── Notifications ───────────────────────────────────────
                  _sectionLabel('Notifications'),
                  _card(
                    child: Column(children: [
                      _switchRow(
                        'Pestering mode',
                        'Randomly sends AI pester messages about pending tasks',
                        profile.pesteringEnabled,
                        (v) async {
                          profile.pesteringEnabled = v;
                          await app.updateProfile(profile);
                        },
                      ),
                      Divider(color: ScreechColors.glassBorder, height: 1),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pester interval',
                                  style: GoogleFonts.inter(
                                      color: ScreechColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(
                                'Every ${profile.pesterIntervalMinutes} min',
                                style: GoogleFonts.inter(
                                    color: ScreechColors.textMuted,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Slider(
                          value: profile.pesterIntervalMinutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: ScreechColors.primary,
                          onChanged: (v) async {
                            profile.pesterIntervalMinutes = v.toInt();
                            await app.updateProfile(profile);
                          },
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // ── Danger zone ─────────────────────────────────────────
                  _sectionLabel('⚠  Danger Zone'),
                  _card(
                    child: Column(children: [
                      // Expandable trigger
                      GestureDetector(
                        onTap: () =>
                            setState(() => _dangerExpanded = !_dangerExpanded),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ScreechColors.danger.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DANGER',
                              style: GoogleFonts.inter(
                                color: ScreechColors.danger,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Advanced overrides',
                              style: GoogleFonts.inter(
                                color: ScreechColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            _dangerExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: ScreechColors.textMuted,
                          ),
                        ]),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _dangerExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Divider(
                                      color: ScreechColors.glassBorder,
                                      height: 1),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Custom Pester Prompt',
                                    style: GoogleFonts.inter(
                                      color: ScreechColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Override the prompt used to generate your pester messages. '
                                    'Use {taskTitle} and {username} as placeholders. Leave blank for default.',
                                    style: GoogleFonts.inter(
                                        color: ScreechColors.textMuted,
                                        fontSize: 12,
                                        height: 1.5),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _promptCtrl,
                                    style: const TextStyle(
                                        color: ScreechColors.textPrimary,
                                        fontSize: 13),
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintText:
                                          'e.g. You are a sarcastic butler named Reginald...',
                                      hintStyle: const TextStyle(
                                          color: ScreechColors.textMuted),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: ScreechColors.glassBorder),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ScreechColors.danger.withAlpha(40),
                                        foregroundColor: ScreechColors.danger,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _savePrompt(app),
                                      child: Text('Save Prompt',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Save ───────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _save(app),
                      child: Text(
                        _isSaving ? 'Saving...' : 'Save Settings',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],

                // ── Keys section (opened directly from side panel) ────────
                if (isKeys) ...[
                  _sectionLabel('AI Keys'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ScreechColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: ScreechColors.primary.withAlpha(40)),
                    ),
                    child: Text(
                      'Keys are stored locally on your device only. '
                      'Screech uses Gemma 3 27B (primary) and Gemini 2.5 Flash Lite (fallback) — get a free key at aistudio.google.com.',
                      style: GoogleFonts.inter(
                          color: ScreechColors.textSecondary,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                  _card(
                    child: Column(children: [
                      TextField(
                        controller: _geminiCtrl,
                        obscureText: !_showGeminiKey,
                        style: const TextStyle(color: ScreechColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Gemini / Gemma API Key',
                          hintText: 'AIzaSy...',
                          prefixIcon: const Icon(Icons.auto_awesome_rounded,
                              color: ScreechColors.textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showGeminiKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ScreechColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _showGeminiKey = !_showGeminiKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _todoistCtrl,
                        obscureText: !_showTodoistToken,
                        style: const TextStyle(color: ScreechColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Todoist API Token',
                          prefixIcon: const Icon(Icons.sync_rounded,
                              color: ScreechColors.textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showTodoistToken
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ScreechColors.textMuted,
                            ),
                            onPressed: () => setState(
                                () => _showTodoistToken = !_showTodoistToken),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _save(app),
                      child: Text(
                        _isSaving ? 'Saving...' : 'Save Keys',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: GoogleFonts.inter(
            color: ScreechColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: ScreechColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ScreechColors.glassBorder),
        ),
        child: child,
      );

  Widget _switchRow(
    String title,
    String subtitle,
    bool value,
    Future<void> Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: ScreechColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            Text(subtitle,
                style: GoogleFonts.inter(
                    color: ScreechColors.textMuted, fontSize: 12)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: (v) => onChanged(v),
          activeColor: ScreechColors.primary,
        ),
      ]),
    );
  }

  Future<void> _save(AppProvider app) async {
    setState(() => _isSaving = true);
    final profile = app.profile;
    profile.username = _usernameCtrl.text.trim().isEmpty
        ? 'User'
        : _usernameCtrl.text.trim();
    profile.geminiApiKey =
        _geminiCtrl.text.trim().isEmpty ? null : _geminiCtrl.text.trim();
    profile.todoistToken =
        _todoistCtrl.text.trim().isEmpty ? null : _todoistCtrl.text.trim();
    await app.updateProfile(profile);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: ScreechColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _savePrompt(AppProvider app) async {
    final v = _promptCtrl.text.trim();
    await app.setCustomPesterPrompt(v.isEmpty ? null : v);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pester prompt saved',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: ScreechColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }
}
