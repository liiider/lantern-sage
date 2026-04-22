import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/ask_question.dart';
import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';
import 'payment_bridge_screen.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({
    required this.repository,
    this.initialQuestionType,
    this.selectionRequestId = 0,
    super.key,
  });

  final LanternRepository repository;
  final int? initialQuestionType;
  final int selectionRequestId;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  late final Future<List<AskQuestion>> _questionsFuture;

  AskQuestion? _selectedQuestion;
  AskAnswer? _answer;
  bool _isAsking = false;
  bool _offline = false;
  int? _handledSelectionRequestId;

  @override
  void initState() {
    super.initState();
    _questionsFuture = widget.repository.getAskQuestions();
    _handleIncomingSelection();
  }

  @override
  void didUpdateWidget(covariant AskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionRequestId != widget.selectionRequestId ||
        oldWidget.initialQuestionType != widget.initialQuestionType) {
      _handleIncomingSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AskQuestion>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        final questions = snapshot.data ?? askQuestions;
        final offline = _offline || snapshot.hasError;

        return LanternPage(
          icon: Icons.help_outline,
          title: 'Ask',
          children: [
            const PageHeader(
              headline: 'Choose a question.',
              subtitle:
                  'Select one fixed question for a focused read. This is a deliberate consultation, not a chat.',
            ),
            const UsageBar(label: 'Free reads today', value: '1 of 2 used'),
            if (offline)
              const _AskStatus(
                  text: 'Using sample questions until the service responds.'),
            for (final question in questions)
              ClickCard(
                title: question.text,
                subtitle: question.available
                    ? question.hint
                    : 'Currently unavailable',
                selected: _selectedQuestion?.type == question.type,
                onTap:
                    question.available ? () => _selectQuestion(question) : null,
                trailing: _QuestionStateMark(
                  selected: _selectedQuestion?.type == question.type,
                ),
              ),
            if (_isAsking)
              const RitualCard(
                child: LinearProgressIndicator(),
              ),
            if (_answer != null) _AskAnswerCard(answer: _answer!),
            ConvertPanel(
              label: 'Need something more specific?',
              title: 'Important Date Pack',
              copy:
                  'A focused read built around one date, one event, and one clearer window.',
              actionLabel: 'Open date pack',
              onTap: () => _openPaidBridge(context, 'Important Date Pack'),
              secondaryActionLabel: 'See Plus',
              onSecondaryTap: () =>
                  _openPaidBridge(context, 'Lantern Sage Plus'),
            ),
          ],
        );
      },
    );
  }

  void _openPaidBridge(BuildContext context, String offerName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentBridgeScreen(offerName: offerName),
      ),
    );
  }

  Future<void> _handleIncomingSelection() async {
    final questionType = widget.initialQuestionType;
    if (questionType == null ||
        _handledSelectionRequestId == widget.selectionRequestId) {
      return;
    }

    _handledSelectionRequestId = widget.selectionRequestId;
    final questions = await _questionsFuture;
    if (!mounted) {
      return;
    }

    AskQuestion? matching;
    for (final question in questions) {
      if (question.available && question.type == questionType) {
        matching = question;
        break;
      }
    }
    if (matching != null) {
      await _selectQuestion(matching);
    }
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

class _QuestionStateMark extends StatelessWidget {
  const _QuestionStateMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: selected ? 'Selected' : 'Ask',
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: LanternSageTheme.accent.withValues(
              alpha: selected ? 0.55 : 0.22,
            ),
          ),
          color: selected
              ? LanternSageTheme.accent.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            selected ? Icons.check : Icons.arrow_forward,
            size: selected ? 15 : 14,
            color: selected
                ? LanternSageTheme.textStrong
                : LanternSageTheme.textSoft,
          ),
        ),
      ),
    );
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
          const SectionLabel('Today\'s read'),
          const SizedBox(height: 12),
          Text(answer.shortAnswer,
              style: Theme.of(context).textTheme.headlineMedium),
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
          SectionLabel(label),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
