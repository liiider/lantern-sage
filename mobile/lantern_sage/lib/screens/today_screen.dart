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
    super.key,
  });

  final LanternRepository repository;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late Future<TodayRead> _todayFuture;
  late Future<FeedbackState> _feedbackFuture;

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

        return _TodayContent(
          read: read,
          offline: offline,
          feedbackFuture: _feedbackFuture,
          onSubmitFeedback: _submitFeedback,
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

class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.read,
    required this.offline,
    required this.feedbackFuture,
    required this.onSubmitFeedback,
  });

  final TodayRead read;
  final bool offline;
  final Future<FeedbackState> feedbackFuture;
  final Future<void> Function(String rating) onSubmitFeedback;

  @override
  Widget build(BuildContext context) {
    return LanternPage(
      title: 'Today',
      subtitle: read.dateLabel,
      children: [
        if (offline)
          const _InlineStatus(
            text: 'Using saved sample guidance while the service is unavailable.',
          ),
        RitualCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(read.lunarLabel, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 18),
              Text(read.title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 18),
              Text(read.practicalTip, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: read.compass
                    .map(
                      (item) => _CompassChip(
                        direction: item.direction,
                        label: item.label,
                        quality: item.quality,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _GuidancePanel(
                title: 'Good for',
                items: read.goodFor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GuidancePanel(
                title: 'Avoid',
                items: read.avoid,
              ),
            ),
          ],
        ),
        RitualCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timing guidance', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 14),
              _TimingRow(label: 'Best time to go out', value: read.bestTime),
              const Divider(color: LanternSageTheme.divider, height: 24),
              _TimingRow(label: 'Time to avoid', value: read.avoidTime),
            ],
          ),
        ),
        _FeedbackCard(
          feedbackFuture: feedbackFuture,
          onSubmit: onSubmitFeedback,
        ),
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
              Text('Evening feedback', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 12),
              Text(
                submitted ? 'Marked as ${_ratingLabel(rating)}.' : 'How did today feel?',
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
        foregroundColor: widget.selected ? LanternSageTheme.background : LanternSageTheme.accent,
        backgroundColor: widget.selected ? LanternSageTheme.accent : Colors.transparent,
        side: const BorderSide(color: LanternSageTheme.divider),
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

class _CompassChip extends StatelessWidget {
  const _CompassChip({
    required this.direction,
    required this.label,
    required this.quality,
  });

  final String direction;
  final String label;
  final String quality;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: LanternSageTheme.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$direction / $label / $quality',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _GuidancePanel extends StatelessWidget {
  const _GuidancePanel({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Text(item, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  const _TimingRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
