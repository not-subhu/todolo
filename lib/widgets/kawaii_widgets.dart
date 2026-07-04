// Shared UI widgets used across the app.
// Named after the old "KawaiiQuest" brand but now using ScreechColors/design.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';

// ── Glass card ─────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double glassLevel;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glassLevel = 0.5,
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: padding,
        decoration: BoxDecoration(
          color: ScreechColors.bgCard,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: ScreechColors.glassBorder),
        ),
        child: child,
      ),
    );
  }
}

// ── Primary button ─────────────────────────────────────────────────────────
class KawaiiButton extends StatelessWidget {
  final String label;
  /// Accepts both synchronous and asynchronous callbacks, or null (disabled).
  final Function? onTap;
  final bool isOutlined;
  final IconData? icon;

  const KawaiiButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : ScreechColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: isOutlined
              ? Border.all(color: ScreechColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: isOutlined ? ScreechColors.primary : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coin display ───────────────────────────────────────────────────────────
class CoinDisplay extends StatelessWidget {
  final int coins;
  final double? fontSize;
  final bool showLabel;
  const CoinDisplay({
    super.key,
    required this.coins,
    this.fontSize,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final fz = fontSize ?? 14.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x40F59E0B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.toll_rounded, color: const Color(0xFFF59E0B), size: fz + 2),
          const SizedBox(width: 5),
          Text(
            showLabel ? '$coins coins' : '$coins',
            style: GoogleFonts.inter(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.w800,
              fontSize: fz,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class KawaiiEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const KawaiiEmptyState({
    super.key,
    this.emoji = '(◕‿◕✿)',
    required this.title,
    this.subtitle = '',
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji,
                style: TextStyle(
                    fontSize: emoji.length < 4 ? 48 : 28,
                    color: ScreechColors.textMuted)),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                color: ScreechColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                    color: ScreechColors.textMuted,
                    fontSize: 13,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: ScreechColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Priority badge ─────────────────────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const PriorityBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Level progress bar ────────────────────────────────────────────────────
class LevelProgressBar extends StatelessWidget {
  final int level;
  final double progress;
  final String title;

  const LevelProgressBar({
    super.key,
    required this.level,
    required this.progress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Lv.$level ',
                    style: GoogleFonts.inter(
                      color: ScreechColors.primaryLit,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: title,
                    style: GoogleFonts.inter(
                      color: ScreechColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.inter(
                color: ScreechColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 6,
          percent: progress.clamp(0.0, 1.0),
          backgroundColor: ScreechColors.bgPanel,
          progressColor: ScreechColors.primary,
          barRadius: const Radius.circular(3),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: ScreechColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      color: ScreechColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Pester overlay ────────────────────────────────────────────────────────
class PesterOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onGoToTask;

  const PesterOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
    required this.onGoToTask,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withAlpha(160),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // absorb taps
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ScreechColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ScreechColors.primary.withAlpha(60)),
                boxShadow: [
                  BoxShadow(
                    color: ScreechColors.primary.withAlpha(40),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: ScreechColors.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('ヾ(≧▽≦*)o', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      color: ScreechColors.textPrimary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onGoToTask,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: ScreechColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Do it now',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: onDismiss,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: ScreechColors.bgPanel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ScreechColors.glassBorder),
                            ),
                            child: Text(
                              'Later...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: ScreechColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().scale(
                duration: 350.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.8, 0.8),
              ),
        ),
      ),
    );
  }
}
