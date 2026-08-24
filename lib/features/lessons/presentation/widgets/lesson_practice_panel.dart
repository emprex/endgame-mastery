import 'package:flutter/material.dart';

class LessonPracticePanel extends StatelessWidget {
  const LessonPracticePanel({
    super.key,
    required this.lessonTitle,
    required this.objective,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final String lessonTitle;
  final String objective;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Practice lesson',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(20),
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
              'PRACTICE',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFFE8C76A),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              lessonTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              objective,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Explore the position on the board. '
              'When you are ready to test your understanding, start the proof.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 18),
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
