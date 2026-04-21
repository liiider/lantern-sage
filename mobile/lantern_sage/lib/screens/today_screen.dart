import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/feedback_state.dart';
import '../models/today_read.dart';
import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    required this.repository,
    this.onAskQuestion,
    super.key,
  });

  final LanternRepository repository;
  final ValueChanged<int>? onAskQuestion;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late Future<TodayRead> _todayFuture;
  late Future<FeedbackState> _feedbackFuture;
  bool _showMoreHours = false;

  @override
  void initState() {
    super.initState();
    _todayFuture = widget.repository.getToday();
    _feedbackFuture = widget.repository.getFeedbackStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TodayRead>(
      future: _todayFuture,
      builder: (context, snapshot) {
        final read = snapshot.data ?? demoToday;
        final offline = snapshot.hasError;

        return LanternPage(
          icon: Icons.wb_twilight_outlined,
          title: read.dateLabel,
          subtitle: read.lunarLabel,
          children: [
            if (offline)
              const _InlineStatus(
                text:
                    'Using saved sample guidance while the service is unavailable.',
              ),
            _HeroRead(read: read),
            _JudgmentCard(read: read),
            _HourlySection(
              read: read,
              showMore: _showMoreHours,
              onToggle: () => setState(() => _showMoreHours = !_showMoreHours),
            ),
            const RitualSeparator(),
            _AskPreview(onAskQuestion: widget.onAskQuestion),
            _FeedbackCard(
              feedbackFuture: _feedbackFuture,
              onSubmit: _submitFeedback,
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback(String rating) async {
    final next = widget.repository.submitFeedback(rating);
    setState(() {
      _feedbackFuture = next;
    });
    await next;
  }
}

class _HeroRead extends StatelessWidget {
  const _HeroRead({required this.read});

  final TodayRead read;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      hero: true,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _CompassPainter(read.compass),
                ),
                const SealGlyph(size: 88),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            read.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const RitualSeparator(),
          const SizedBox(height: 10),
          Text(
            read.practicalTip,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _JudgmentCard extends StatelessWidget {
  const _JudgmentCard({required this.read});

  final TodayRead read;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        children: [
          _JudgmentRow(
            icon: Icons.check_circle_outline,
            label: 'Good for',
            items: read.goodFor,
          ),
          Divider(
              color: LanternSageTheme.accent.withValues(alpha: 0.08),
              height: 24),
          _JudgmentRow(
            icon: Icons.cancel_outlined,
            label: 'Avoid',
            items: read.avoid,
          ),
        ],
      ),
    );
  }
}

class _JudgmentRow extends StatelessWidget {
  const _JudgmentRow({
    required this.icon,
    required this.label,
    required this.items,
  });

  final IconData icon;
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LanternSageTheme.textSoft, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items) RitualTag(text: item),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HourlySection extends StatelessWidget {
  const _HourlySection({
    required this.read,
    required this.showMore,
    required this.onToggle,
  });

  final TodayRead read;
  final bool showMore;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final slots = [
      _HourSlot(
          time: read.bestTime,
          badge: 'Now',
          goodFor: read.goodFor.take(4).toList(),
          avoid: read.avoid.take(2).toList(),
          current: true),
      _HourSlot(
          time: read.avoidTime,
          badge: 'Next',
          goodFor: read.goodFor.skip(1).take(3).toList(),
          avoid: read.avoid.take(2).toList()),
      if (showMore)
        _HourSlot(
            time: '1:00 PM - 3:00 PM',
            goodFor: read.goodFor.take(3).toList(),
            avoid: read.avoid.take(2).toList()),
      if (showMore)
        _HourSlot(
            time: '3:00 PM - 5:00 PM',
            goodFor: read.goodFor.reversed.take(3).toList(),
            avoid: read.avoid.reversed.take(2).toList()),
    ];

    return Column(
      children: [
        for (final slot in slots) ...[
          slot,
          const SizedBox(height: 10),
        ],
        TextButton(
          onPressed: onToggle,
          child: Text(showMore ? 'Hide hours' : 'Show more hours'),
        ),
      ],
    );
  }
}

class _HourSlot extends StatelessWidget {
  const _HourSlot({
    required this.time,
    required this.goodFor,
    required this.avoid,
    this.badge,
    this.current = false,
  });

  final String time;
  final String? badge;
  final List<String> goodFor;
  final List<String> avoid;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LanternSageTheme.accent.withValues(alpha: current ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: LanternSageTheme.accent
                .withValues(alpha: current ? 0.15 : 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(time,
                        style: Theme.of(context).textTheme.titleMedium)),
                if (badge != null) RitualTag(text: badge!, accent: current),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _MiniTagColumn(label: 'Good for', items: goodFor)),
                const SizedBox(width: 10),
                Expanded(child: _MiniTagColumn(label: 'Avoid', items: avoid)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTagColumn extends StatelessWidget {
  const _MiniTagColumn({required this.label, required this.items});

  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [for (final item in items) RitualTag(text: item)],
        ),
      ],
    );
  }
}

class _AskPreview extends StatelessWidget {
  const _AskPreview({required this.onAskQuestion});

  final ValueChanged<int>? onAskQuestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final question in askQuestions.take(3)) ...[
          ClickCard(
            title: question.text,
            subtitle: 'Tap Ask below to continue',
            onTap: onAskQuestion == null
                ? null
                : () => onAskQuestion!(question.type),
            trailing: DecoratedBox(
              decoration: BoxDecoration(
                color: LanternSageTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: LanternSageTheme.accent.withValues(alpha: 0.2)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Text('Ask'),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedbackFuture,
    required this.onSubmit,
  });

  final Future<FeedbackState> feedbackFuture;
  final Future<void> Function(String rating) onSubmit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedbackState>(
      future: feedbackFuture,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final submitted = state?.submitted ?? false;
        final rating = state?.rating;

        return RitualCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Evening feedback'),
              const SizedBox(height: 12),
              Text(
                submitted
                    ? 'Marked as ${_ratingLabel(rating)}.'
                    : 'How did today feel?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _FeedbackButton(rating: 'accurate', label: 'Accurate'),
                  _FeedbackButton(rating: 'neutral', label: 'Neutral'),
                  _FeedbackButton(rating: 'inaccurate', label: 'Inaccurate'),
                ].map((button) {
                  return _FeedbackAction(
                    button: button,
                    selected: rating == button.rating,
                    onSubmit: onSubmit,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _ratingLabel(String? rating) {
    switch (rating) {
      case 'accurate':
        return 'Accurate';
      case 'neutral':
        return 'Neutral';
      case 'inaccurate':
        return 'Inaccurate';
      default:
        return 'submitted';
    }
  }
}

class _FeedbackButton {
  const _FeedbackButton({
    required this.rating,
    required this.label,
  });

  final String rating;
  final String label;
}

class _FeedbackAction extends StatefulWidget {
  const _FeedbackAction({
    required this.button,
    required this.selected,
    required this.onSubmit,
  });

  final _FeedbackButton button;
  final bool selected;
  final Future<void> Function(String rating) onSubmit;

  @override
  State<_FeedbackAction> createState() => _FeedbackActionState();
}

class _FeedbackActionState extends State<_FeedbackAction> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _submitting ? null : _submit,
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.selected
            ? LanternSageTheme.background
            : LanternSageTheme.accent,
        backgroundColor:
            widget.selected ? LanternSageTheme.accent : Colors.transparent,
      ),
      child: Text(_submitting ? 'Saving' : widget.button.label),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(widget.button.rating);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter(this.items);

  final List<CompassItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final linePaint = Paint()
      ..color = LanternSageTheme.accent.withValues(alpha: 0.24)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labels = items.isEmpty
        ? const [
            CompassItem(direction: 'N', label: 'Wealth', quality: 'open'),
            CompassItem(direction: 'S', label: 'Blessing', quality: 'steady'),
            CompassItem(direction: 'E', label: 'Movement', quality: 'light'),
            CompassItem(direction: 'W', label: 'Rest', quality: 'quiet'),
          ]
        : items;

    for (var i = 0; i < 8; i++) {
      final angle = (-90 + i * 45) * 3.14159 / 180;
      final start = Offset(
          center.dx + 48 * math.cos(angle), center.dy + 48 * math.sin(angle));
      final end = Offset(
          center.dx + 96 * math.cos(angle), center.dy + 96 * math.sin(angle));
      canvas.drawLine(start, end, linePaint);

      final item = labels[i % labels.length];
      textPainter.text = TextSpan(
        text: i % 2 == 0 ? item.label : item.quality,
        style: TextStyle(
          color: LanternSageTheme.accent
              .withValues(alpha: i % 3 == 0 ? 0.82 : 0.6),
          fontSize: 9,
          letterSpacing: 1,
        ),
      );
      textPainter.layout();
      final labelPoint = Offset(
          center.dx + 108 * math.cos(angle), center.dy + 108 * math.sin(angle));
      textPainter.paint(canvas,
          labelPoint - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.items != items;
}
