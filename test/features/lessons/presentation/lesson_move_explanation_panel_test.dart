import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Practice hides coaching when no explanation exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPracticePanel(
            lessonTitle: 'Key Squares',
            objective: 'Understand key squares.',
            primaryActionLabel: 'Start Prove',
            onPrimaryAction: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-explanation')),
      findsNothing,
    );
  });

  testWidgets('Practice displays verified move explanation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPracticePanel(
            lessonTitle: 'Key Squares',
            objective: 'Understand key squares.',
            primaryActionLabel: 'Start Prove',
            onPrimaryAction: () {},
            explanationTitle: 'Key-square geometry changed',
            explanationMessage:
                'Re-evaluate which squares the king must reach.',
          ),
        ),
      ),
    );

    expect(find.text('COACHING'), findsOneWidget);

    expect(find.text('Key-square geometry changed'), findsOneWidget);

    expect(
      find.text('Re-evaluate which squares the king must reach.'),
      findsOneWidget,
    );
  });

  testWidgets('Prove displays verified move explanation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProvePanel(
            stageLabel: 'PROVE',
            stageTitle: 'Prove it',
            explanationTitle: 'Key-square geometry changed',
            explanationMessage: 'The relevant key squares have changed.',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-explanation')),
      findsOneWidget,
    );

    expect(find.text('COACHING'), findsOneWidget);
  });
}
