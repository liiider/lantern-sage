import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RitualCard extends StatelessWidget {
  const RitualCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.hero = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(hero ? 14 : 10);
    final borderColor = selected
        ? LanternSageTheme.accent.withValues(alpha: 0.5)
        : LanternSageTheme.accent.withValues(alpha: hero ? 0.25 : 0.12);
    final fill = hero
        ? LanternSageTheme.heroSurface
        : selected
            ? LanternSageTheme.accent.withValues(alpha: 0.08)
            : LanternSageTheme.surfaceMuted;

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: hero ? 2 : 1),
        boxShadow: hero
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: LanternSageTheme.accent.withValues(alpha: 0.12),
                  blurRadius: 80,
                  offset: const Offset(0, 28),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RitualSurfacePainter(hero: hero),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return decorated;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: decorated,
      ),
    );
  }
}

class ClickCard extends StatelessWidget {
  const ClickCard({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing ?? const ArrowGlyph(),
        ],
      ),
    );
  }
}

class RitualTag extends StatelessWidget {
  const RitualTag({
    required this.text,
    this.accent = false,
    super.key,
  });

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LanternSageTheme.accent.withValues(alpha: accent ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              LanternSageTheme.accent.withValues(alpha: accent ? 0.28 : 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class RitualSeparator extends StatelessWidget {
  const RitualSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Rule(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CustomPaint(painter: SealMarkPainter(faint: true)),
          ),
        ),
        _Rule(),
      ],
    );
  }
}

class ArrowGlyph extends StatelessWidget {
  const ArrowGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_forward,
      color: LanternSageTheme.textSoft,
      size: 18,
    );
  }
}

class SealGlyph extends StatelessWidget {
  const SealGlyph({
    this.size = 88,
    this.faint = false,
    super.key,
  });

  final double size;
  final bool faint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: SealMarkPainter(faint: faint)),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 1,
      color: LanternSageTheme.lineSoft,
    );
  }
}

class _RitualSurfacePainter extends CustomPainter {
  const _RitualSurfacePainter({required this.hero});

  final bool hero;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = LanternSageTheme.accent.withValues(alpha: hero ? 0.12 : 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    if (hero) {
      final inset = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inset, const Radius.circular(10)),
        linePaint,
      );

      const corner = 24.0;
      final cornerPaint = Paint()
        ..color = LanternSageTheme.accent.withValues(alpha: 0.2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      for (final origin in [
        const Offset(12, 12),
        Offset(size.width - 12 - corner, 12),
        Offset(12, size.height - 12 - corner),
        Offset(size.width - 12 - corner, size.height - 12 - corner),
      ]) {
        canvas.drawRect(
            Rect.fromLTWH(origin.dx, origin.dy, corner, corner), cornerPaint);
      }
    }

    final fiberPaint = Paint()
      ..color = LanternSageTheme.accent.withValues(alpha: hero ? 0.025 : 0.015)
      ..strokeWidth = 1;
    for (double x = 18; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), fiberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RitualSurfacePainter oldDelegate) {
    return oldDelegate.hero != hero;
  }
}

class SealMarkPainter extends CustomPainter {
  const SealMarkPainter({this.faint = false});

  final bool faint;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 128;
    final scaleY = size.height / 128;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final body = Paint()
      ..color = LanternSageTheme.panelDark
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = LanternSageTheme.accent.withValues(alpha: faint ? 0.42 : 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyPath = Path()
      ..moveTo(31, 13)
      ..cubicTo(45, 9, 78, 10, 95, 18)
      ..cubicTo(108, 24, 114, 37, 112, 53)
      ..cubicTo(118, 68, 116, 89, 104, 101)
      ..cubicTo(91, 114, 70, 117, 53, 114)
      ..cubicTo(39, 118, 24, 110, 18, 95)
      ..cubicTo(11, 83, 11, 65, 16, 50)
      ..cubicTo(15, 35, 19, 21, 31, 13)
      ..close();
    canvas.drawPath(bodyPath, body);
    canvas.drawPath(bodyPath, stroke..strokeWidth = 1.2);

    stroke.strokeWidth = 2.4;
    final glyph = Path()
      ..moveTo(62, 33)
      ..lineTo(62, 77)
      ..moveTo(46, 48)
      ..cubicTo(50, 40, 56, 36, 64, 36)
      ..cubicTo(70, 36, 76, 39, 82, 46)
      ..moveTo(45, 63)
      ..cubicTo(52, 62, 59, 62, 67, 62)
      ..cubicTo(72, 62, 77, 62, 83, 63)
      ..moveTo(50, 79)
      ..cubicTo(54, 84, 59, 87, 65, 87)
      ..cubicTo(72, 87, 78, 84, 83, 78)
      ..moveTo(55, 94)
      ..lineTo(77, 94);
    canvas.drawPath(glyph, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SealMarkPainter oldDelegate) {
    return oldDelegate.faint != faint;
  }
}
