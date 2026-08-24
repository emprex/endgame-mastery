import 'package:flutter/material.dart';

class LessonCompletedPanel extends StatelessWidget {
  const LessonCompletedPanel({
    super.key,
    required this.lessonTitle,
    required this.curriculumEnd,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final String lessonTitle;
  final bool curriculumEnd;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Lesson completed',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF242329),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 42, color: Color(0xFFE8C76A)),
            const SizedBox(height: 12),
            Text(
              'LESSON COMPLETE',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFFE8C76A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lessonTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              curriculumEnd
                  ? 'You have completed the currently available curriculum.'
                  : 'You are ready for the next lesson.',
              key: const ValueKey<String>('lesson-completed-message'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            if (onPrimaryAction != null && primaryActionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey<String>('lesson-next-button'),
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
