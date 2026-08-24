import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen() {
    return const MaterialApp(
      home: LessonExperienceScreen(
        board: ColoredBox(
          key: ValueKey<String>('test-board'),
          color: Colors.black,
        ),
      ),
    );
  }

  testWidgets('starts in Learn with board interaction locked', (tester) async {
    await tester.pumpWidget(buildScreen());

    expect(find.text('LEARN'), findsOneWidget);
    expect(find.text('Key Squares'), findsOneWidget);
    expect(find.text('Start Practice'), findsOneWidget);

    final gate = tester.widget<IgnorePointer>(
      find.byKey(const ValueKey<String>('lesson-board-interaction-gate')),
    );

    expect(gate.ignoring, isTrue);
  });

  testWidgets('Start Practice advances the session and unlocks the board', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    final startPractice = find.text('Start Practice');

    expect(startPractice, findsOneWidget);

    await tester.ensureVisible(startPractice);
    await tester.pumpAndSettle();

    await tester.tap(startPractice);
    await tester.pumpAndSettle();

    expect(find.text('LEARN'), findsNothing);

    final gate = tester.widget<IgnorePointer>(
      find.byKey(const ValueKey<String>('lesson-board-interaction-gate')),
    );

    expect(gate.ignoring, isFalse);

    expect(find.byKey(const ValueKey<String>('test-board')), findsOneWidget);
  });

  testWidgets('Learn experience fits a narrow mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('Key Squares'), findsOneWidget);

    final startPractice = find.text('Start Practice');

    expect(startPractice, findsOneWidget);

    await tester.ensureVisible(startPractice);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Learn experience fits a wide desktop viewport', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('LEARN'), findsOneWidget);

    expect(find.byKey(const ValueKey<String>('test-board')), findsOneWidget);
  });
}
