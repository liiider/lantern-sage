import 'package:flutter/material.dart';

import '../services/lantern_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.repository,
    required this.onCompleted,
    super.key,
  });

  final LanternRepository repository;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _LocationChoice _selected = _LocationChoice.choices.first;
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return LanternPage(
      title: 'Lantern Sage',
      subtitle: 'Begin with your local rhythm',
      children: [
        RitualCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the city and timezone you want today\'s guidance to follow.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<_LocationChoice>(
                initialValue: _selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Location'),
                items: [
                  for (final choice in _LocationChoice.choices)
                    DropdownMenuItem(
                      value: choice,
                      child: Text(
                        '${choice.city} / ${choice.timezone}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (choice) {
                        if (choice != null) {
                          setState(() => _selected = choice);
                        }
                      },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: LanternSageTheme.accent)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _continueAsGuest,
                  child: Text(_submitting ? 'Starting' : 'Continue as guest'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.repository.getOrRegisterGuest(
        city: _selected.city,
        timezone: _selected.timezone,
      );
      if (mounted) {
        widget.onCompleted();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not start guest mode. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _LocationChoice {
  const _LocationChoice({
    required this.city,
    required this.timezone,
  });

  final String city;
  final String timezone;

  static const choices = [
    _LocationChoice(city: 'Shanghai', timezone: 'Asia/Shanghai'),
    _LocationChoice(city: 'New York', timezone: 'America/New_York'),
    _LocationChoice(city: 'Los Angeles', timezone: 'America/Los_Angeles'),
    _LocationChoice(city: 'London', timezone: 'Europe/London'),
    _LocationChoice(city: 'Singapore', timezone: 'Asia/Singapore'),
    _LocationChoice(city: 'Sydney', timezone: 'Australia/Sydney'),
  ];
}
