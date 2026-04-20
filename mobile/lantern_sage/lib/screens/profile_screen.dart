import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/demo_data.dart';
import '../models/important_date_guidance.dart';
import '../models/user_profile.dart';
import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.repository,
    super.key,
  });

  final LanternRepository repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  ImportantDateGuidance? _importantDateGuidance;
  bool _isLoadingImportantDate = false;
  bool _importantDateOffline = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.repository.getOrRegisterGuest();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return LanternPage(
          title: 'Profile',
          subtitle: 'Guest / MVP access',
          children: [
            if (snapshot.hasError)
              const _SettingCard(
                title: 'Connection',
                value: 'Profile will sync when the service is available.',
              ),
            _SettingCard(
              title: 'Location',
              value: profile == null
                  ? 'Shanghai / Asia Shanghai'
                  : '${profile.city} / ${profile.timezone}',
              actionLabel: 'Change',
              onTap: profile == null ? null : () => _openLocationSheet(profile),
            ),
            _SettingCard(
              title: 'Evening reminder',
              value: profile?.reminderTime ?? '20:00',
            ),
            const _SettingCard(
              title: 'Daily guidance',
              value: 'Today, Ask, History, and feedback are open for MVP testing.',
            ),
            _SettingCard(
              title: 'Important date guidance',
              value: 'Choose one date and event for focused timing guidance.',
              actionLabel: 'Open',
              onTap: _openImportantDateSheet,
            ),
            if (_isLoadingImportantDate)
              const RitualCard(child: LinearProgressIndicator()),
            if (_importantDateOffline)
              const _SettingCard(
                title: 'Connection',
                value: 'Showing sample date guidance until the service responds.',
              ),
            if (_importantDateGuidance != null)
              _ImportantDateCard(guidance: _importantDateGuidance!),
          ],
        );
      },
    );
  }

  Future<void> _openLocationSheet(UserProfile profile) async {
    final result = await showModalBottomSheet<_LocationChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSheet(profile: profile),
    );
    if (result == null) {
      return;
    }

    final next = widget.repository.updateSettings(
      city: result.city,
      timezone: result.timezone,
    );
    setState(() {
      _profileFuture = next;
    });
    await next;
  }

  Future<void> _openImportantDateSheet() async {
    final request = await showModalBottomSheet<_ImportantDateRequestDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ImportantDateSheet(),
    );
    if (request == null) {
      return;
    }

    setState(() {
      _isLoadingImportantDate = true;
      _importantDateOffline = false;
    });

    try {
      final guidance = await widget.repository.getImportantDateGuidance(
        targetDate: request.targetDate,
        eventType: request.eventType,
      );
      if (!mounted) {
        return;
      }
      setState(() => _importantDateGuidance = guidance);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _importantDateGuidance = demoImportantDate;
        _importantDateOffline = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingImportantDate = false);
      }
    }
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.value,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String value;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onTap,
                  child: Text(actionLabel!),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _LocationChoice {
  const _LocationChoice({
    required this.city,
    required this.timezone,
  });

  final String city;
  final String timezone;
}

class _LocationSheet extends StatelessWidget {
  const _LocationSheet({required this.profile});

  final UserProfile profile;

  static const choices = [
    _LocationChoice(city: 'Shanghai', timezone: 'Asia/Shanghai'),
    _LocationChoice(city: 'New York', timezone: 'America/New_York'),
    _LocationChoice(city: 'Los Angeles', timezone: 'America/Los_Angeles'),
    _LocationChoice(city: 'London', timezone: 'Europe/London'),
    _LocationChoice(city: 'Singapore', timezone: 'Asia/Singapore'),
    _LocationChoice(city: 'Sydney', timezone: 'Australia/Sydney'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF241006),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose location', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          for (final choice in choices)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(choice.city),
              subtitle: Text(choice.timezone),
              trailing: choice.city == profile.city && choice.timezone == profile.timezone
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.of(context).pop(choice),
            ),
        ],
      ),
    );
  }
}

class _ImportantDateRequestDraft {
  const _ImportantDateRequestDraft({
    required this.targetDate,
    required this.eventType,
  });

  final DateTime targetDate;
  final String eventType;
}

class _ImportantDateSheet extends StatefulWidget {
  const _ImportantDateSheet();

  @override
  State<_ImportantDateSheet> createState() => _ImportantDateSheetState();
}

class _ImportantDateSheetState extends State<_ImportantDateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))),
  );

  String _eventType = 'meeting';

  static const _eventTypes = [
    DropdownMenuItem(value: 'general', child: Text('General plan')),
    DropdownMenuItem(value: 'travel', child: Text('Travel')),
    DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
    DropdownMenuItem(value: 'move', child: Text('Moving or setup')),
    DropdownMenuItem(value: 'signing', child: Text('Signing')),
    DropdownMenuItem(value: 'home', child: Text('Home adjustment')),
  ];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF241006),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Important date', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'YYYY-MM-DD',
                ),
                keyboardType: TextInputType.datetime,
                validator: _validateDate,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _eventType,
                decoration: const InputDecoration(labelText: 'Event'),
                items: _eventTypes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _eventType = value);
                  }
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Get guidance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateDate(String? value) {
    final raw = value?.trim() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null || DateFormat('yyyy-MM-dd').format(parsed) != raw) {
      return 'Use YYYY-MM-DD.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _ImportantDateRequestDraft(
        targetDate: DateTime.parse(_dateController.text.trim()),
        eventType: _eventType,
      ),
    );
  }
}

class _ImportantDateCard extends StatelessWidget {
  const _ImportantDateCard({required this.guidance});

  final ImportantDateGuidance guidance;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(guidance.targetDate, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(guidance.summary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          _GuidanceRow(label: 'Best window', value: guidance.bestWindow),
          _GuidanceRow(label: 'Caution window', value: guidance.cautionWindow),
          _GuidanceRow(label: 'Day quality', value: guidance.dayQuality),
          _GuidanceRow(label: 'Small action', value: guidance.practicalTip),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in guidance.goodFor)
                _GuidanceChip(text: item, tone: _GuidanceChipTone.open),
              for (final item in guidance.avoid)
                _GuidanceChip(text: item, tone: _GuidanceChipTone.caution),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidanceRow extends StatelessWidget {
  const _GuidanceRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

enum _GuidanceChipTone { open, caution }

class _GuidanceChip extends StatelessWidget {
  const _GuidanceChip({
    required this.text,
    required this.tone,
  });

  final String text;
  final _GuidanceChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isOpen = tone == _GuidanceChipTone.open;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isOpen
            ? LanternSageTheme.accent.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen
              ? LanternSageTheme.accent.withValues(alpha: 0.45)
              : LanternSageTheme.textFaint.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
