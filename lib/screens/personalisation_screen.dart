import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class PersonalisationScreen extends StatefulWidget {
  const PersonalisationScreen({super.key});
  @override
  State<PersonalisationScreen> createState() => _PersonalisationScreenState();
}

class _PersonalisationScreenState extends State<PersonalisationScreen> {
  static const _swatches = [
    Color(0xFF7C3AED), // Default purple
    Color(0xFF2563EB), // Blue
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFFDC2626), // Red
    Color(0xFFDB2777), // Pink
    Color(0xFF7C3AED), // Violet
    Color(0xFF0891B2), // Cyan
    Color(0xFF9333EA), // Fuchsia
    Color(0xFF16A34A), // Green
  ];

  final _quoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().profile;
    _quoteCtrl.text = p.motivationQuote ?? '';
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, app, _) {
        final p = app.profile;
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
              'Personalisation',
              style: GoogleFonts.inter(
                  color: ScreechColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Mode ──────────────────────────────────────────────────────
              _sectionTitle('Appearance'),
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark mode',
                              style: GoogleFonts.inter(
                                  color: ScreechColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                          Text('Light mode is experimental',
                              style: GoogleFonts.inter(
                                  color: ScreechColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: p.isDarkMode,
                      onChanged: (v) => app.setDarkMode(v),
                      activeColor: app.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Primary colour ─────────────────────────────────────────
              _sectionTitle('Primary Colour'),
              _card(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _swatches.map((color) {
                    final selected = p.primaryColor.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () => app.setPrimaryColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: color.withAlpha(120), blurRadius: 12)]
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Glass level ────────────────────────────────────────────
              _sectionTitle('Glass Effect'),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Glass level',
                            style: GoogleFonts.inter(
                                color: ScreechColors.textPrimary,
                                fontWeight: FontWeight.w600)),
                        Text(
                          _glassLabel(p.glassLevel),
                          style: GoogleFonts.inter(
                              color: ScreechColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    Slider(
                      value: p.glassLevel,
                      min: 0,
                      max: 1,
                      divisions: 4,
                      activeColor: app.primaryColor,
                      onChanged: (v) => app.setGlassLevel(v),
                    ),
                    // Preview card at current glass level
                    Container(
                      height: 60,
                      decoration: AppTheme.glassCardWith(
                          glassLevel: p.glassLevel, radius: 12),
                      child: Center(
                        child: Text('Preview',
                            style: GoogleFonts.inter(
                                color: ScreechColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Header image ───────────────────────────────────────────
              _sectionTitle('Header Image'),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose the background image shown at the top of your home screen.',
                      style: GoogleFonts.inter(
                          color: ScreechColors.textSecondary, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _imageOption(
                          ctx,
                          label: 'Default',
                          assetPath: 'assets/images/motivation_girl.png',
                          selected: p.headerImagePath == null ||
                              p.headerImagePath == 'assets/images/motivation_girl.png',
                          onTap: () => app.setHeaderImage(null),
                        ),
                        const SizedBox(width: 10),
                        _imageOption(
                          ctx,
                          label: 'Mascot',
                          assetPath: 'assets/images/mascot.png',
                          selected: p.headerImagePath == 'assets/images/mascot.png',
                          onTap: () => app.setHeaderImage('assets/images/mascot.png'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Motivation quote ───────────────────────────────────────
              _sectionTitle('Motivation Quote'),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Override the rotating quotes. Leave blank for auto-rotate.',
                      style: GoogleFonts.inter(
                          color: ScreechColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _quoteCtrl,
                      style: const TextStyle(color: ScreechColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. Discipline today, freedom tomorrow.',
                        hintStyle: const TextStyle(color: ScreechColors.textMuted),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_rounded,
                              color: ScreechColors.primaryLit),
                          onPressed: () {
                            final v = _quoteCtrl.text.trim();
                            app.setMotivationQuote(v.isEmpty ? null : v);
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Quote saved',
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                backgroundColor: ScreechColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  String _glassLabel(double v) {
    if (v < 0.2) return 'None';
    if (v < 0.4) return 'Subtle';
    if (v < 0.6) return 'Medium';
    if (v < 0.8) return 'High';
    return 'Maximum';
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: GoogleFonts.inter(
                color: ScreechColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.8)),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ScreechColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ScreechColors.glassBorder),
        ),
        child: child,
      );

  Widget _imageOption(
    BuildContext ctx, {
    required String label,
    required String assetPath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? context.read<AppProvider>().primaryColor
                  : ScreechColors.glassBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(assetPath, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: ScreechColors.bgPanel)),
                if (selected)
                  Container(
                    color: Colors.black.withAlpha(80),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                Positioned(
                  bottom: 6, left: 0, right: 0,
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
