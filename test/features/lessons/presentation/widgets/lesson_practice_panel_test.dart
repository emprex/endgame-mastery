import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildPanel({VoidCallback? onPrimaryAction}) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: LessonPracticePanel(
          lessonTitle: 'Key Squares',
          objective: 'Understand what key squares are and why the side to move matters.',
          primaryActionLabel: 'Start Prove',
          onPrimaryAction: onPrimaryAction ?? () {},
        ),
      ),
    );
  }

  testWidgets('renders practice guidance', (tester) async {
    await tester.pumpWidget(buildPanel());

    expect(find.text('PRACTICE'), findsOneWidget);

    expect(find.text('Key Squares'), findsOneWidget);

    expect(find.text('Start Prove'), findsOneWidget);
  });

  testWidgets('invokes Start Prove action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      buildPanel(
        onPrimaryAction: () {
          pressed = true;
        },
      ),
    );

    await tester.tap(find.text('Start Prove'));

    await tester.pump();

    expect(pressed, isTrue);
  });
}
