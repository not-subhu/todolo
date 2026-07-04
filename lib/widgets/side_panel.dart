import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import '../screens/personalisation_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

class SidePanel extends StatelessWidget {
  final UserProfile profile;
  const SidePanel({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.76,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: ScreechColors.bgPanel,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo + app name ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/screech_logo.png',
                        width: 44, height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: ScreechColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.pets_rounded, color: ScreechColors.primaryLit),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Screech',
                          style: GoogleFonts.inter(
                            color: ScreechColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          profile.username,
                          style: GoogleFonts.inter(
                            color: ScreechColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: ScreechColors.glassBorder, height: 1, indent: 24, endIndent: 24),
              const SizedBox(height: 12),

              // ── Navigation items ─────────────────────────────────────────
              _NavItem(
                icon: Icons.palette_outlined,
                label: 'Personalisation',
                subtitle: 'Colors, themes, header image',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    _slideRoute(const PersonalisationScreen()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.key_rounded,
                label: 'Keys',
                subtitle: 'Gemini, Todoist API keys',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    _slideRoute(const SettingsScreen(initialSection: SettingsSection.keys)),
                  );
                },
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                subtitle: 'Notifications, Danger zone',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    _slideRoute(const SettingsScreen()),
                  );
                },
              ),

              const Spacer(),

              // ── Stats summary ────────────────────────────────────────────
              Consumer<AppProvider>(
                builder: (ctx, app, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ScreechColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ScreechColors.primary.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('${app.profile.currentStreak}', '🔥 Streak'),
                        _divider(),
                        _stat('${app.profile.availableCoins}', '◆ Coins'),
                        _divider(),
                        _stat('Lv.${app.profile.level}', 'Level'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.inter(
                color: ScreechColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                color: ScreechColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: ScreechColors.glassBorder,
      );

  Route _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: ScreechColors.primary.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ScreechColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ScreechColors.primaryLit, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: ScreechColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: ScreechColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: ScreechColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
