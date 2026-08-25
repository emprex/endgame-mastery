import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_route_screen.dart';
import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:endgame_mastery/features/progress/domain/lesson_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('opening a lesson persists last lesson and in-progress state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();

    final repository = SharedPreferencesLessonProgressRepository(preferences);

    await tester.pumpWidget(
      MaterialApp(
        home: LessonRouteScreen(
          lesson: keySquaresLesson03,
          lessonNumber: 3,
          progressRepository: repository,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(await repository.lastLessonId(), keySquaresLesson03.id);

    final progress = await repository.progressFor(keySquaresLesson03.id);

    expect(progress.status, LessonProgressStatus.inProgress);
  });

  testWidgets('opening a completed lesson does not downgrade its progress', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();

    final repository = SharedPreferencesLessonProgressRepository(preferences);

    await repository.markCompleted(keySquaresLesson02.id);

    await tester.pumpWidget(
      MaterialApp(
        home: LessonRouteScreen(
          lesson: keySquaresLesson02,
          lessonNumber: 2,
          progressRepository: repository,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final progress = await repository.progressFor(keySquaresLesson02.id);

    expect(progress.status, LessonProgressStatus.completed);

    expect(await repository.lastLessonId(), keySquaresLesson02.id);
  });
}
