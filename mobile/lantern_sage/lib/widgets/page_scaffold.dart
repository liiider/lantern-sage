import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ritual_card.dart';

class LanternPage extends StatelessWidget {
  const LanternPage({
    required this.title,
    required this.children,
    this.subtitle,
    this.icon = Icons.auto_awesome,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 452),
                child: _Masthead(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  theme: theme,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 104),
          sliver: SliverList.separated(
            itemBuilder: (context, index) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 452),
                  child: children[index],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemCount: children.length,
          ),
        ),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: LanternSageTheme.textSoft, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.labelSmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelSmall);
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.headline,
    required this.subtitle,
    super.key,
  });

  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headline, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class UsageBar extends StatelessWidget {
  const UsageBar({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: LanternSageTheme.accent.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: SectionLabel(label)),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class ConvertPanel extends StatelessWidget {
  const ConvertPanel({
    required this.label,
    required this.title,
    required this.copy,
    required this.actionLabel,
    required this.onTap,
    this.secondaryActionLabel,
    this.onSecondaryTap,
    super.key,
  });

  final String label;
  final String title;
  final String copy;
  final String actionLabel;
  final VoidCallback onTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      hero: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(copy, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: onTap,
                child: Text(actionLabel),
              ),
              if (secondaryActionLabel != null)
                OutlinedButton(
                  onPressed: onSecondaryTap,
                  child: Text(secondaryActionLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
