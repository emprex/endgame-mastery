import 'package:flutter/material.dart';

class LessonResultPanel extends StatelessWidget {
  const LessonResultPanel({
    super.key,
    required this.resultTitle,
    required this.resultMessage,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final String resultTitle;
  final String resultMessage;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Lesson result',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF242329),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RESULT',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFFE8C76A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resultTitle,
              key: const ValueKey<String>('proof-result-title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              resultMessage,
              key: const ValueKey<String>('proof-result-message'),
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPrimaryAction,
                child: Text(primaryActionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
