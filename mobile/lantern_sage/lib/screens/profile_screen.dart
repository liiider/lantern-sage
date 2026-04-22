import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/demo_data.dart';
import '../models/important_date_guidance.dart';
import '../models/user_profile.dart';
import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';
import 'payment_bridge_screen.dart';

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
          icon: Icons.person_outline,
          title: 'Profile',
          subtitle: 'Guest / Free tier',
          children: [
            if (snapshot.hasError)
              const _SettingCard(
                title: 'Connection',
                value: 'Profile will sync when the service is available.',
              ),
            _ProfileIdentity(profile: profile),
            const RitualSeparator(),
            const SectionLabel('Settings'),
            _SettingsGroup(
              profile: profile,
              onLocationTap:
                  profile == null ? null : () => _openLocationSheet(profile),
            ),
            const SectionLabel('Subscription'),
            _UpgradeCard(
              onTap: () => _openPaidBridge('Lantern Sage Plus'),
            ),
            const SectionLabel('One-time packs'),
            _SettingCard(
              title: 'Important Date Pack',
              value: 'Focused read for a specific date or event.',
              actionLabel: 'Open',
              onTap: _openImportantDateSheet,
            ),
            ClickCard(
              title: 'Purchase Important Date Pack',
              subtitle: 'Unlock one focused read for a specific date or event',
              onTap: () => _openPaidBridge('Important Date Pack'),
            ),
            if (_isLoadingImportantDate)
              const RitualCard(child: LinearProgressIndicator()),
            if (_importantDateOffline)
              const _SettingCard(
                title: 'Connection',
                value:
                    'Showing sample date guidance until the service responds.',
              ),
            if (_importantDateGuidance != null)
              _ImportantDateCard(guidance: _importantDateGuidance!),
            const RitualSeparator(),
            const SectionLabel('Account'),
            const _SettingCard(
                title: 'Sign in or create account', value: 'Coming later'),
            const _SettingCard(
                title: 'Privacy policy', value: 'MVP placeholder'),
            const _SettingCard(
                title: 'Terms of service', value: 'MVP placeholder'),
            const _AppInfo(),
          ],
        );
      },
    );
  }

  void _openPaidBridge(String offerName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentBridgeScreen(offerName: offerName),
      ),
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

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: LanternSageTheme.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: LanternSageTheme.accent.withValues(alpha: 0.2),
            ),
          ),
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              Icons.person_outline,
              color: LanternSageTheme.textFaint,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                profile == null ? 'Free tier' : '${profile?.city} / Free tier',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.profile,
    required this.onLocationTap,
  });

  final UserProfile? profile;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final city = profile?.city ?? 'Shanghai';
    final timezone = profile?.timezone ?? 'Asia/Shanghai';
    final reminder = profile?.reminderTime ?? '20:00';

    return RitualCard(
      child: Column(
        children: [
          _SettingRow(
            label: 'Timezone',
            value: timezone,
            onTap: onLocationTap,
          ),
          const _SettingDivider(),
          _SettingRow(
            label: 'City',
            value: city,
            onTap: onLocationTap,
          ),
          const _SettingDivider(),
          const _SettingRow(label: 'Language', value: 'English'),
          const _SettingDivider(),
          _SettingRow(
            label: 'Evening reminder',
            value: _formatReminder(reminder),
          ),
        ],
      ),
    );
  }

  String _formatReminder(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return value;
    }
    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null || minute == null) {
      return value;
    }
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const ArrowGlyph(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: LanternSageTheme.accent.withValues(alpha: 0.08),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      hero: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.layers_outlined,
            color: LanternSageTheme.accent,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text('Lantern Sage Plus',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'More daily reads, deeper timing guidance, 30-day history, and richer home adjustment suggestions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onTap, child: const Text('See plans')),
        ],
      ),
    );
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
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            Text(actionLabel!, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 8),
            const ArrowGlyph(),
          ],
        ],
      ),
    );
  }
}

class _AppInfo extends StatelessWidget {
  const _AppInfo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lantern Sage v1.0\nCalm guidance, better timing.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF241006),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose location',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            for (final choice in choices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(choice.city),
                subtitle: Text(choice.timezone),
                trailing: choice.city == profile.city &&
                        choice.timezone == profile.timezone
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(choice),
              ),
          ],
        ),
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
    text: DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 7))),
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
      child: SingleChildScrollView(
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
                Text('Important date',
                    style: Theme.of(context).textTheme.titleLarge),
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
      ),
    );
  }

  String? _validateDate(String? value) {
    final raw = value?.trim() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null || DateFormat('yyyy-MM-dd').format(parsed) != raw) {
      return 'Use YYYY-MM-DD.';
    }
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final parsedOnly = DateTime(parsed.year, parsed.month, parsed.day);
    if (parsedOnly.isBefore(todayOnly)) {
      return 'Choose today or a future date.';
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
          Text(guidance.targetDate,
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(guidance.summary,
              style: Theme.of(context).textTheme.titleMedium),
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
