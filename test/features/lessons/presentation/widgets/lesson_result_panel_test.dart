import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_result_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders proof result and Continue action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: LessonResultPanel(
            resultTitle: 'Passed',
            resultMessage:
                'Your result matches the verified theoretical result.',
            primaryActionLabel: 'Continue',
            onPrimaryAction: () {},
          ),
        ),
      ),
    );

    expect(find.text('RESULT'), findsOneWidget);

    expect(find.text('Passed'), findsOneWidget);

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('invokes Continue action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonResultPanel(
            resultTitle: 'Passed',
            resultMessage: 'Proof complete.',
            primaryActionLabel: 'Continue',
            onPrimaryAction: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));

    await tester.pump();

    expect(pressed, isTrue);
  });
}
