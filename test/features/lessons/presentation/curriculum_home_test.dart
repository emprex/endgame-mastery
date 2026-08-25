import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home derives lesson availability from curriculum', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EndgameMasteryApp());

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('available-lesson-count')),
      findsOneWidget,
    );

    expect(
      find.text('${curriculum.length} verified lessons available'),
      findsOneWidget,
    );

    for (final lesson in curriculum) {
      expect(
        find.byKey(ValueKey<String>('lesson-card-${lesson.id}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('home exposes a continue learning entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EndgameMasteryApp());

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('continue-learning-card')),
      findsOneWidget,
    );
  });
}
