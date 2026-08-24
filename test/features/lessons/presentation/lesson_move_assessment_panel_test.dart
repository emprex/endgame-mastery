import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Practice hides concept check without assessment', (
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
      find.byKey(const ValueKey<String>('lesson-move-assessment')),
      findsNothing,
    );

    expect(find.text('CONCEPT CHECK'), findsNothing);
  });

  testWidgets('Practice displays curriculum assessment', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPracticePanel(
            lessonTitle: 'Key Squares',
            objective: 'Understand key squares.',
            primaryActionLabel: 'Start Prove',
            onPrimaryAction: () {},
            assessmentTitle: 'You reached a key square',
            assessmentMessage: 'c6 is a verified key square in this position.',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-assessment')),
      findsOneWidget,
    );

    expect(find.text('CONCEPT CHECK'), findsOneWidget);

    expect(find.text('You reached a key square'), findsOneWidget);
  });

  testWidgets('Prove displays curriculum assessment', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProvePanel(
            stageLabel: 'PROVE',
            stageTitle: 'Prove it',
            assessmentTitle: 'You reached a key square',
            assessmentMessage: 'c6 is a verified key square in this position.',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-move-assessment')),
      findsOneWidget,
    );

    expect(find.text('CONCEPT CHECK'), findsOneWidget);
  });
}
