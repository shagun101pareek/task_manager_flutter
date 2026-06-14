import 'dart:ui';

import 'package:flutter/material.dart';

class AppAssets {
  static const background = 'assets/images/background.jpg';
}

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({
    super.key,
    required this.child,
    this.blurSigma = 10,
    this.overlayColor,
  });

  final Widget child;
  final double blurSigma;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: isDark ? 0.2 : 0.45,
          child: Image.asset(
            AppAssets.background,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Container(color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFF)),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: Container(color: Colors.transparent),
          ),
        ),
        Container(
          color: overlayColor ??
              (isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.72)),
        ),
        child,
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isDark
            ? const Color(0xFF1E2832).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        border: Border.all(
          color: isDark
              ? const Color(0xFF37474F)
              : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
