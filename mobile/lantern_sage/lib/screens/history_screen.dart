import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../services/lantern_repository.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';
import 'payment_bridge_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.repository,
    super.key,
  });

  final LanternRepository repository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryEntry>>(
      future: repository.getHistory(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <HistoryEntry>[];

        return LanternPage(
          icon: Icons.history_outlined,
          title: 'History',
          children: [
            const PageHeader(
              headline: 'Recent rhythm.',
              subtitle: 'A quiet record of recent days. Rhythm, not data.',
            ),
            if (snapshot.hasError)
              const _HistoryStatus(
                  text: 'History will appear after the service is available.'),
            if (!snapshot.hasError &&
                snapshot.connectionState == ConnectionState.waiting)
              const RitualCard(child: LinearProgressIndicator()),
            if (!snapshot.hasError &&
                snapshot.connectionState != ConnectionState.waiting &&
                entries.isEmpty)
              const _HistoryStatus(
                  text: 'Your recent daily rhythm will collect here.'),
            for (final entry in entries) _HistoryEntryCard(entry: entry),
            const RitualSeparator(),
            ConvertPanel(
              label: 'Lantern Sage Plus',
              title: 'See your full 30-day rhythm.',
              copy:
                  'Unlock repeated patterns, deeper weekly summaries, and a longer view of recent days.',
              actionLabel: 'See Plus',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const PaymentBridgeScreen(offerName: 'Lantern Sage Plus'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryStatus extends StatelessWidget {
  const _HistoryStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final feedback = entry.feedback == null ? 'No feedback' : entry.feedback!;

    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.date,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(entry.dayOfWeek,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  RitualTag(text: feedback),
                  RitualTag(text: '${entry.askCount} asks'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.message.isEmpty ? 'No daily read yet.' : entry.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _EntryBlock(
                      label: 'Good for', copy: entry.goodForSummary)),
              const SizedBox(width: 14),
              Expanded(
                  child: _EntryBlock(label: 'Avoid', copy: entry.avoidSummary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryBlock extends StatelessWidget {
  const _EntryBlock({required this.label, required this.copy});

  final String label;
  final String copy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Text(copy.isEmpty ? 'Pending' : copy,
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
