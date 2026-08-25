import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('user can open a lesson and return to the lesson library', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EndgameMasteryApp());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final lessonCard = find.byKey(
      ValueKey<String>('lesson-card-${keySquaresLesson01.id}'),
    );

    expect(lessonCard, findsOneWidget);

    await tester.ensureVisible(lessonCard);
    await tester.pump();

    await tester.tap(lessonCard);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('lesson-back-to-library')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-restart')),
      findsOneWidget,
    );

    final backButton = find.byKey(
      const ValueKey<String>('lesson-back-to-library'),
    );

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.text('Pawn Endgames'), findsOneWidget);
  });
}
