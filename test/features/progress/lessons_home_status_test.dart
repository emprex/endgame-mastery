import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lessons_screen.dart';
import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'home displays persisted lesson statuses and completion percentage',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final preferences = await SharedPreferences.getInstance();

      final repository = SharedPreferencesLessonProgressRepository(preferences);

      await repository.markCompleted(keySquaresLesson01.id);
      await repository.markCompleted(keySquaresLesson02.id);
      await repository.markInProgress(keySquaresLesson03.id);
      await repository.setLastLesson(keySquaresLesson03.id);

      await tester.pumpWidget(
        MaterialApp(home: LessonsScreen(progressRepository: repository)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(ValueKey<String>('lesson-status-${keySquaresLesson01.id}')),
        findsOneWidget,
      );

      expect(
        find.byKey(ValueKey<String>('lesson-status-${keySquaresLesson03.id}')),
        findsOneWidget,
      );

      expect(
        find.text('2 of ${curriculum.length} lessons completed'),
        findsOneWidget,
      );

      final expectedPercentage = ((2 / curriculum.length) * 100).round();

      expect(find.text('$expectedPercentage%'), findsOneWidget);

      expect(find.text('Lesson 3'), findsOneWidget);
    },
  );
}
