import 'package:flutter/material.dart';

import '../widgets/page_scaffold.dart';
import '../widgets/ritual_card.dart';

class PaymentBridgeScreen extends StatelessWidget {
  const PaymentBridgeScreen({
    required this.offerName,
    super.key,
  });

  final String offerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LanternPage(
          icon: Icons.payments_outlined,
          title: 'Payment bridge',
          subtitle: offerName,
          children: [
            RitualCard(
              hero: true,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 260),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SealGlyph(size: 96),
                    const SizedBox(height: 20),
                    Text(
                      'Payment handoff placeholder',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This empty bridge stands in for the future checkout provider.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                PaidAccessScreen(offerName: offerName),
                          ),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaidAccessScreen extends StatelessWidget {
  const PaidAccessScreen({
    required this.offerName,
    super.key,
  });

  final String offerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LanternPage(
          icon: Icons.workspace_premium_outlined,
          title: 'Access active',
          subtitle: offerName,
          children: [
            RitualCard(
              hero: true,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SealGlyph(size: 96),
                  const SizedBox(height: 20),
                  Text(
                    '$offerName is active.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offerName == 'Important Date Pack'
                        ? 'The focused date guidance flow is ready for use.'
                        : 'Plus access is shown as active for the MVP paid-state screen.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
