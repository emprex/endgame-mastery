import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/teaching/pedagogical_move_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PedagogicalMoveAssessment', () {
    final move = PlayedMove(from: 'd5', to: 'c6');

    test('preserves curriculum coaching assessment', () {
      final assessment = PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.reinforcesConcept,
        title: 'You reached a key square',
        message:
            'The king has reached a verified key square for this position.',
        source: PedagogicalAssessmentSource.curriculum,
      );

      expect(assessment.move.uci, 'd5c6');

      expect(assessment.quality, PedagogicalMoveQuality.reinforcesConcept);

      expect(assessment.source, PedagogicalAssessmentSource.curriculum);

      expect(assessment.isKnown, isTrue);
      expect(assessment.reinforcesConcept, isTrue);
      expect(assessment.needsAttention, isFalse);
    });

    test('supports conservative unknown assessment', () {
      final assessment = PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.unknown,
        title: 'No verified assessment',
        message: 'The curriculum does not yet classify this move.',
        source: PedagogicalAssessmentSource.curriculum,
      );

      expect(assessment.isKnown, isFalse);
      expect(assessment.reinforcesConcept, isFalse);
      expect(assessment.needsAttention, isFalse);
    });

    test('trims learner-facing text', () {
      final assessment = PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.needsAttention,
        title: '  Reconsider the plan  ',
        message: '  Focus on the verified key squares.  ',
        source: PedagogicalAssessmentSource.curriculum,
      );

      expect(assessment.title, 'Reconsider the plan');

      expect(assessment.message, 'Focus on the verified key squares.');
    });

    test('rejects empty title', () {
      expect(
        () => PedagogicalMoveAssessment(
          move: move,
          quality: PedagogicalMoveQuality.unknown,
          title: '   ',
          message: 'No verified assessment.',
          source: PedagogicalAssessmentSource.curriculum,
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty message', () {
      expect(
        () => PedagogicalMoveAssessment(
          move: move,
          quality: PedagogicalMoveQuality.unknown,
          title: 'No verified assessment',
          message: '   ',
          source: PedagogicalAssessmentSource.curriculum,
        ),
        throwsArgumentError,
      );
    });
  });
}
