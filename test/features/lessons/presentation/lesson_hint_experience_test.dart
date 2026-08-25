import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen() {
    return const MaterialApp(
      home: LessonExperienceScreen(board: ColoredBox(color: Colors.black)),
    );
  }

  testWidgets('Practice reveals three hints progressively', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Practice'));
    await tester.pumpAndSettle();

    expect(find.text('Get a hint'), findsOneWidget);
    expect(find.text('Hint 1 of 3'), findsNothing);

    await tester.tap(find.text('Get a hint'));
    await tester.pumpAndSettle();

    expect(find.text('Hint 1 of 3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('lesson-current-hint')),
        matching: find.textContaining('key square'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Show visual hint'));
    await tester.pumpAndSettle();

    expect(find.text('Hint 1 of 3'), findsNothing);
    expect(find.text('Hint 2 of 3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('lesson-current-hint')),
        matching: find.textContaining('c6, d6, and e6'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Show targeted hint'));
    await tester.pumpAndSettle();

    expect(find.text('Hint 2 of 3'), findsNothing);
    expect(find.text('Hint 3 of 3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('lesson-current-hint')),
        matching: find.textContaining('theoretical draw'),
      ),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('lesson-hint-button')),
      findsNothing,
    );
  });

  testWidgets('Starting Prove resets Practice hints', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Practice'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get a hint'));
    await tester.pumpAndSettle();

    expect(find.text('Hint 1 of 3'), findsOneWidget);

    await tester.tap(find.text('Start Prove'));
    await tester.pumpAndSettle();

    expect(find.text('PROVE'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('lesson-current-hint')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('lesson-hint-progress')),
      findsNothing,
    );
    expect(find.text('Get a hint'), findsOneWidget);
  });
}
