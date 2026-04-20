import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/ask_question.dart';
import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({
    required this.repository,
    super.key,
  });

  final LanternRepository repository;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  late final Future<List<AskQuestion>> _questionsFuture;

  AskQuestion? _selectedQuestion;
  AskAnswer? _answer;
  bool _isAsking = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = widget.repository.getAskQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AskQuestion>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        final questions = snapshot.data ?? askQuestions;
        final offline = _offline || snapshot.hasError;

        return LanternPage(
          title: 'Ask',
          subtitle: 'Free reads today',
          children: [
            if (offline)
              const _AskStatus(text: 'Using sample questions until the service responds.'),
            for (final question in questions)
              RitualCard(
                onTap: question.available ? () => _selectQuestion(question) : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.text, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            question.available ? question.hint : 'Currently unavailable',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _selectedQuestion?.type == question.type
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: question.available
                          ? LanternSageTheme.accent
                          : LanternSageTheme.textFaint,
                      size: 22,
                    ),
                  ],
                ),
              ),
            if (_isAsking)
              const RitualCard(
                child: LinearProgressIndicator(),
              ),
            if (_answer != null)
              _AskAnswerCard(answer: _answer!),
          ],
        );
      },
    );
  }

  Future<void> _selectQuestion(AskQuestion question) async {
    setState(() {
      _selectedQuestion = question;
      _answer = null;
      _isAsking = true;
      _offline = false;
    });

    try {
      final answer = await widget.repository.askQuestion(question.type);
      if (!mounted) {
        return;
      }
      setState(() => _answer = answer);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _answer = demoAnswer;
        _offline = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isAsking = false);
      }
    }
  }
}

class _AskStatus extends StatelessWidget {
  const _AskStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _AskAnswerCard extends StatelessWidget {
  const _AskAnswerCard({required this.answer});

  final AskAnswer answer;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s read', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          Text(answer.shortAnswer, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _AnswerRow(label: 'Window', value: answer.recommendedTime),
          _AnswerRow(label: 'Caution', value: answer.caution),
          _AnswerRow(label: 'Reason', value: answer.reason),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
