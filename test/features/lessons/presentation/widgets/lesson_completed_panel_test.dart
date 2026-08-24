import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_completed_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders curriculum end state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: LessonCompletedPanel(
            lessonTitle: 'Key Squares',
            curriculumEnd: true,
          ),
        ),
      ),
    );

    expect(find.text('LESSON COMPLETE'), findsOneWidget);

    expect(find.text('Key Squares'), findsOneWidget);

    expect(
      find.text('You have completed the currently available curriculum.'),
      findsOneWidget,
    );
  });

  testWidgets('renders next lesson state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonCompletedPanel(
            lessonTitle: 'Key Squares',
            curriculumEnd: false,
          ),
        ),
      ),
    );

    expect(find.text('You are ready for the next lesson.'), findsOneWidget);
  });
}
