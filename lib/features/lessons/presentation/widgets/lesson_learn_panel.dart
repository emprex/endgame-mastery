import 'package:flutter/material.dart';

class LessonLearnPanel extends StatelessWidget {
  const LessonLearnPanel({
    super.key,
    required this.lessonTitle,
    required this.objective,
    required this.learnText,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final String lessonTitle;
  final String objective;
  final String learnText;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Learn lesson',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF242329),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEARN',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFFE8C76A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _Section(
              title: 'Objective',
              child: Text(
                objective,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _Section(
              title: 'Concept',
              child: Text(
                learnText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPrimaryAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(primaryActionLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}
