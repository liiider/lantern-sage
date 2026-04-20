import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../services/lantern_repository.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

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
          title: 'History',
          subtitle: 'Recent rhythm',
          children: [
            if (snapshot.hasError)
              const _HistoryStatus(text: 'History will appear after the service is available.'),
            if (!snapshot.hasError && snapshot.connectionState == ConnectionState.waiting)
              const RitualCard(child: LinearProgressIndicator()),
            if (!snapshot.hasError &&
                snapshot.connectionState != ConnectionState.waiting &&
                entries.isEmpty)
              const _HistoryStatus(text: 'Your recent daily rhythm will collect here.'),
            for (final entry in entries)
              _HistoryEntryCard(entry: entry),
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
    final feedback = entry.feedback == null ? 'feedback pending' : entry.feedback!;

    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.dayOfWeek} / ${entry.date}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 10),
          Text(
            entry.message.isEmpty ? 'No daily read yet.' : entry.message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '${entry.askCount} asks / $feedback',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
