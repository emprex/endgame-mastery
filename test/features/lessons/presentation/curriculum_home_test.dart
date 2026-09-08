import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openTrainingLibrary(WidgetTester tester) async {
    await tester.pumpWidget(const EndgameMasteryApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Training'));
    await tester.pumpAndSettle();
  }

  testWidgets('training library derives lesson availability from curriculum', (
    WidgetTester tester,
  ) async {
    await openTrainingLibrary(tester);

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

  testWidgets('training library exposes a continue learning entry point', (
    WidgetTester tester,
  ) async {
    await openTrainingLibrary(tester);

    expect(
      find.byKey(const ValueKey<String>('continue-learning-card')),
      findsOneWidget,
    );
  });
}
