import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lessons_screen.dart';
import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('continue learning uses the last opened lesson', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();

    final repository = SharedPreferencesLessonProgressRepository(preferences);

    await repository.setLastLesson(keySquaresLesson03.id);

    await repository.markInProgress(keySquaresLesson03.id);

    await tester.pumpWidget(
      MaterialApp(home: LessonsScreen(progressRepository: repository)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lesson 3'), findsOneWidget);

    expect(find.text(keySquaresLesson03.title), findsWidgets);
  });

  testWidgets(
    'continue learning falls back to first lesson for a new learner',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final preferences = await SharedPreferences.getInstance();

      final repository = SharedPreferencesLessonProgressRepository(preferences);

      await tester.pumpWidget(
        MaterialApp(home: LessonsScreen(progressRepository: repository)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lesson 1'), findsOneWidget);

      expect(find.text(keySquaresLesson01.title), findsWidgets);
    },
  );
}
