import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lesson route navigation fits a narrow mobile viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: LessonRouteScreen(lesson: keySquaresLesson01, lessonNumber: 1),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey<String>('lesson-back-to-library')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-restart')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-route-number')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-route-title')),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
}
