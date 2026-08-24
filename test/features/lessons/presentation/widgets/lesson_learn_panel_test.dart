import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_learn_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildPanel({VoidCallback? onPrimaryAction}) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: LessonLearnPanel(
          lessonTitle: 'Key Squares',
          objective: 'Understand what key squares are.',
          learnText: 'The relevant key squares are c6, d6, and e6.',
          primaryActionLabel: 'Start Practice',
          onPrimaryAction: onPrimaryAction ?? () {},
        ),
      ),
    );
  }

  testWidgets('renders lesson learn content', (tester) async {
    await tester.pumpWidget(buildPanel());

    expect(find.text('LEARN'), findsOneWidget);
    expect(find.text('Key Squares'), findsOneWidget);
    expect(find.text('Objective'), findsOneWidget);
    expect(find.text('Understand what key squares are.'), findsOneWidget);
    expect(find.text('Concept'), findsOneWidget);
    expect(
      find.text('The relevant key squares are c6, d6, and e6.'),
      findsOneWidget,
    );
    expect(find.text('Start Practice'), findsOneWidget);
  });

  testWidgets('invokes primary action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      buildPanel(
        onPrimaryAction: () {
          pressed = true;
        },
      ),
    );

    await tester.tap(find.text('Start Practice'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('fits narrow mobile width without horizontal overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: LessonLearnPanel(
              lessonTitle: 'Key Squares',
              objective: 'Understand what key squares are and why the side to move matters.',
              learnText:
                  'The white king on d5 has not yet reached a key square. '
                  'The relevant key squares are c6, d6, and e6.',
              primaryActionLabel: 'Start Practice',
              onPrimaryAction: _noop,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Key Squares'), findsOneWidget);
  });
}

void _noop() {}
