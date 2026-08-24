import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows prove guidance without a manual completion action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProvePanel(stageLabel: 'PROVE', stageTitle: 'Prove it'),
        ),
      ),
    );

    expect(find.text('PROVE'), findsOneWidget);
    expect(find.text('Prove it'), findsOneWidget);
    expect(find.text('Prove the theoretical result.'), findsOneWidget);

    expect(
      find.text(
        'Play the position to its legitimate conclusion. '
        'The proof ends only when the chess game ends.',
      ),
      findsOneWidget,
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
