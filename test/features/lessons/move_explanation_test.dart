import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/teaching/move_explanation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveExplanation', () {
    final move = PlayedMove(from: 'd4', to: 'd5');

    test('preserves move and verified pedagogical content', () {
      final explanation = MoveExplanation(
        move: move,
        title: 'Key-square geometry changed',
        message: 'The pawn advance changes the relevant key-square geometry.',
        source: MoveExplanationSource.curriculum,
      );

      expect(explanation.move.uci, 'd4d5');

      expect(explanation.title, 'Key-square geometry changed');

      expect(
        explanation.message,
        'The pawn advance changes the relevant key-square geometry.',
      );

      expect(explanation.source, MoveExplanationSource.curriculum);
    });

    test('trims learner-facing text', () {
      final explanation = MoveExplanation(
        move: move,
        title: '  Teaching point  ',
        message: '  Verified explanation.  ',
        source: MoveExplanationSource.curriculum,
      );

      expect(explanation.title, 'Teaching point');

      expect(explanation.message, 'Verified explanation.');
    });

    test('rejects empty title', () {
      expect(
        () => MoveExplanation(
          move: move,
          title: '   ',
          message: 'Verified explanation.',
          source: MoveExplanationSource.curriculum,
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty message', () {
      expect(
        () => MoveExplanation(
          move: move,
          title: 'Teaching point',
          message: '   ',
          source: MoveExplanationSource.curriculum,
        ),
        throwsArgumentError,
      );
    });
  });
}
