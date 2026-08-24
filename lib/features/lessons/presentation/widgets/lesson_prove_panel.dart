import 'package:flutter/material.dart';

class LessonProvePanel extends StatelessWidget {
  const LessonProvePanel({
    super.key,
    required this.stageLabel,
    required this.stageTitle,
    this.hintText,
    this.hintProgressLabel,
    this.hintActionLabel,
    this.onHintRequested,
    this.explanationTitle,
    this.explanationMessage,
    this.assessmentTitle,
    this.assessmentMessage,
  });

  final String stageLabel;
  final String stageTitle;

  final String? hintText;
  final String? hintProgressLabel;
  final String? hintActionLabel;
  final VoidCallback? onHintRequested;

  final String? explanationTitle;
  final String? explanationMessage;

  final String? assessmentTitle;
  final String? assessmentMessage;

  bool get _hasExplanation =>
      explanationTitle != null && explanationMessage != null;

  bool get _hasAssessment =>
      assessmentTitle != null && assessmentMessage != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Prove lesson',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF242329),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stageLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFFE8C76A),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              stageTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Prove the theoretical result.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play the position to its legitimate conclusion. '
              'The proof ends only when the chess game ends.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.white70,
              ),
            ),
            if (_hasExplanation) ...[
              const SizedBox(height: 16),
              _FeedbackCard(
                key: const ValueKey<String>(
                  'lesson-move-explanation',
                ),
                label: 'COACHING',
                title: explanationTitle!,
                message: explanationMessage!,
              ),
            ],
            if (_hasAssessment) ...[
              const SizedBox(height: 12),
              _FeedbackCard(
                key: const ValueKey<String>(
                  'lesson-move-assessment',
                ),
                label: 'CONCEPT CHECK',
                title: assessmentTitle!,
                message: assessmentMessage!,
              ),
            ],
            if (hintText != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hintProgressLabel != null) ...[
                      Text(
                        hintProgressLabel!,
                        key: const ValueKey<String>(
                          'lesson-hint-progress',
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE8C76A),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      hintText!,
                      key: const ValueKey<String>(
                        'lesson-current-hint',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (hintActionLabel != null &&
                onHintRequested != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey<String>(
                    'lesson-hint-button',
                  ),
                  onPressed: onHintRequested,
                  icon: const Icon(
                    Icons.lightbulb_outline,
                  ),
                  label: Text(hintActionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    super.key,
    required this.label,
    required this.title,
    required this.message,
  });

  final String label;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8C76A).withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8C76A).withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: const Color(0xFFE8C76A),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}
