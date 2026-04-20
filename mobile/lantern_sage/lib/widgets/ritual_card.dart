import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RitualCard extends StatelessWidget {
  const RitualCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: LanternSageTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LanternSageTheme.divider),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}
