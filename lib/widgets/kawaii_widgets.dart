import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Coin Display ──────────────────────────────────────────
class CoinDisplay extends StatelessWidget {
  final int coins;
  final double fontSize;
  final bool showLabel;

  const CoinDisplay({
    super.key,
    required this.coins,
    this.fontSize = 18,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: KawaiiColors.gold.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Text('🪙', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 6),
        Text(
          '$coins',
          style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: KawaiiColors.gold,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            'coins',
            style: GoogleFonts.nunito(
              fontSize: fontSize - 4,
              color: KawaiiColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Priority Badge ──────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const PriorityBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Kawaii Button ──────────────────────────────────────────
class KawaiiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  final bool isOutlined;

  const KawaiiButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? KawaiiColors.sakuraPink;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : c,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c, width: isOutlined ? 2 : 0),
          boxShadow: isOutlined
              ? null
              : [BoxShadow(color: c.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isOutlined ? c : Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isOutlined ? c : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: KawaiiColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.nunito(
                      color: KawaiiColors.textMuted,
                      fontSize: 13,
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

// ── Empty State ──────────────────────────────────────────
class KawaiiEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const KawaiiEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.nunito(
                color: KawaiiColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              KawaiiButton(label: actionLabel ?? 'Add one!', onTap: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Glassmorphism Card ──────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha(25),
              Colors.white.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: br,
          border: Border.all(color: Colors.white.withAlpha(25), width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ── Level Progress Bar ──────────────────────────────────────────
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
            Text(
              'Lv.$level · $title',
              style: GoogleFonts.nunito(
                color: KawaiiColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              '${(progress * 100).toInt()} / 100 XP',
              style: GoogleFonts.nunito(
                color: KawaiiColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: KawaiiColors.cardMid,
            valueColor: const AlwaysStoppedAnimation<Color>(KawaiiColors.sakuraPink),
          ),
        ),
      ],
    );
  }
}

// ── Pester Overlay ──────────────────────────────────────────
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
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [KawaiiColors.midPurple, KawaiiColors.cardDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: KawaiiColors.sakuraPink.withAlpha(100), width: 2),
            boxShadow: [
              BoxShadow(
                color: KawaiiColors.sakuraPink.withAlpha(50),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('(ﾉ≧∀≦)ﾉ', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.nunito(
                  color: KawaiiColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: KawaiiButton(
                      label: 'I\'ll do it!',
                      onTap: onGoToTask,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KawaiiButton(
                      label: 'Later...',
                      onTap: onDismiss,
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(
          duration: 400.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        ),
      ),
    );
  }
}
