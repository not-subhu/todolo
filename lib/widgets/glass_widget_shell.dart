/// Shared liquid-glass container used by home-screen widgets.
///
/// [glassLevel] (0.0 → 1.0) controls opacity and blur:
///   0.0 — nearly invisible frosted glass (high blur, low fill)
///   1.0 — denser, more opaque dark panel (lower blur, higher fill)
///
/// Opacity and blur are persisted via AppProvider.glassLevel and can be
/// adjusted from Personalisation → Glass Level.
library;

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassWidgetShell extends StatelessWidget {
  final Widget child;
  final double glassLevel;
  final double radius;
  final EdgeInsets padding;

  const GlassWidgetShell({
    super.key,
    required this.child,
    this.glassLevel = 0.5,
    this.radius = 20,
    this.padding = const EdgeInsets.all(13),
  });

  @override
  Widget build(BuildContext context) {
    // Clamp input first — persisted values can be out of range after a
    // schema migration or manual edit.
    final gl = glassLevel.clamp(0.0, 1.0);

    // glassLevel 0 → 1: more opaque and less blurry as level rises
    final bgAlpha     = (35 + (gl * 145)).toInt().clamp(0, 255);
    final blurSigma   = (14.0 - (gl * 8.0)).clamp(1.0, 20.0); // never 0
    final borderAlpha = (35 + (gl * 55)).toInt().clamp(0, 255);

    // Top-edge shimmer simulates light refraction (liquid glass hallmark).
    // Clamped independently then combined to guarantee the sum ≤ 255.
    final shimmerExtra = (18 - (gl * 10).toInt()).clamp(0, 18);
    final shimmerBg    = (bgAlpha + shimmerExtra).clamp(0, 255);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Top-left is slightly lighter → refraction shimmer
                Color.fromARGB(shimmerBg, 30, 20, 52),
                Color.fromARGB(bgAlpha,   12,  8, 22),
              ],
            ),
            border: Border.all(
              color: Colors.white.withAlpha(borderAlpha),
              width: 0.75,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
