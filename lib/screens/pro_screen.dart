import 'package:flutter/material.dart';
import '../services/pro_service.dart';

class ProScreen extends StatelessWidget {
  final ProService proService;

  const ProScreen({super.key, required this.proService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LazyMedia Pro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pro-версия',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'В этом шаблоне Pro — демонстрационный флаг. Он открывает поиск и избранное.\n\n'
              'Для публикации в Google Play / App Store замените демо-разблокировку на реальный биллинг: '
              'Google Play Billing, App Store In-App Purchase или RevenueCat.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await proService.unlockProDemo();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Включить Pro (демо)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
