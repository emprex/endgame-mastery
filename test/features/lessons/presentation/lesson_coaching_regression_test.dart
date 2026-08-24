import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Practice may display explanation and assessment independently', (
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
            explanationTitle: 'Key-square geometry changed',
            explanationMessage: 'Re-evaluate the relevant key squares.',
            assessmentTitle: 'You reached a key square',
            assessmentMessage: 'c6 is a verified key square.',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-explanation')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-assessment')),
      findsOneWidget,
    );

    expect(find.text('COACHING'), findsOneWidget);

    expect(find.text('CONCEPT CHECK'), findsOneWidget);
  });

  testWidgets('Practice may display assessment without explanation', (
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
            assessmentTitle: 'You reached a key square',
            assessmentMessage: 'c6 is a verified key square.',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-explanation')),
      findsNothing,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-assessment')),
      findsOneWidget,
    );
  });

  testWidgets('Prove never exposes a manual proof completion action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProvePanel(
            stageLabel: 'PROVE',
            stageTitle: 'Prove it',
            assessmentTitle: 'You reached a key square',
            assessmentMessage: 'c6 is a verified key square.',
          ),
        ),
      ),
    );

    expect(find.text('Finish Proof'), findsNothing);

    expect(find.text('Complete Proof'), findsNothing);

    expect(find.text('Finish'), findsNothing);

    expect(find.text('Continue'), findsNothing);
  });
}
