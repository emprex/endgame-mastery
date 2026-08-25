import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('practice navigation does not report a lesson change', (
    WidgetTester tester,
  ) async {
    LessonDefinition? changedLesson;

    await tester.pumpWidget(
      MaterialApp(
        home: LessonExperienceScreen(
          initialLesson: keySquaresLesson01,
          board: const SizedBox.expand(),
          onLessonChanged: (lesson) {
            changedLesson = lesson;
          },
        ),
      ),
    );

    final startPractice = find.text('Start Practice');

    await tester.ensureVisible(startPractice);
    await tester.pump();

    await tester.tap(startPractice);
    await tester.pump();

    while (find.text('Next Practice Position').evaluate().isNotEmpty) {
      final nextPractice = find.text('Next Practice Position');

      await tester.ensureVisible(nextPractice);
      await tester.pump();

      await tester.tap(nextPractice);
      await tester.pump();
    }

    expect(changedLesson, isNull);
  });

  testWidgets('initial lesson load does not emit a lesson changed event', (
    WidgetTester tester,
  ) async {
    LessonDefinition? changedLesson;

    await tester.pumpWidget(
      MaterialApp(
        home: LessonExperienceScreen(
          initialLesson: keySquaresLesson01,
          board: const SizedBox.expand(),
          onLessonChanged: (lesson) {
            changedLesson = lesson;
          },
        ),
      ),
    );

    await tester.pump();

    expect(changedLesson, isNull);
  });
}
