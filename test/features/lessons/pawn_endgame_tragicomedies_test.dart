import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:endgame_mastery/features/lessons/overlay/pedagogical_overlay_engine.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_position_resolver.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dvoretsky Tragicomedies 1-5 and 1-6', () {
    const resolver = LessonPositionResolver();
    const overlayEngine = PedagogicalOverlayEngine();

    test('preserves the exact Diagram 1-5 position and lesson purpose', () {
      const fen = '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1';

      expect(pawnTragicomedyLesson05.fen, fen);
      expect(pawnTragicomedyLesson05.theoreticalResult, TheoreticalResult.draw);
      expect(pawnTragicomedyLesson05Positions.length, 3);
      expect(pawnTragicomedyLesson05.learnText, contains('d5-pawn'));
      expect(pawnTragicomedyLesson05.learnText, contains('resigned'));
      expect(pawnTragicomedyLesson05.learnText, contains('calculation'));

      for (final position in pawnTragicomedyLesson05Positions) {
        expect(position.fen, fen);
      }
    });

    test('preserves the exact Diagram 1-6 position and Rf4 Kg5 warning', () {
      const fen = '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1';

      expect(pawnTragicomedyLesson06.fen, fen);
      expect(pawnTragicomedyLesson06.theoreticalResult, TheoreticalResult.draw);
      expect(pawnTragicomedyLesson06Positions.length, 3);
      expect(pawnTragicomedyLesson06.learnText, contains('1.Rf4??'));
      expect(pawnTragicomedyLesson06.learnText, contains('1...Kg5!'));

      for (final position in pawnTragicomedyLesson06Positions) {
        expect(position.fen, fen);
      }
    });

    test('places both tragicomedies after Diagram 1-4', () {
      expect(curriculum.length, greaterThanOrEqualTo(6));
      expect(curriculum[3].id, keySquaresLesson04.id);
      expect(curriculum[4].id, pawnTragicomedyLesson05.id);
      expect(curriculum[5].id, pawnTragicomedyLesson06.id);
    });

    test('resolver keeps exact book positions for Practice and Prove', () {
      for (final lesson in <LessonDefinition>[
        pawnTragicomedyLesson05,
        pawnTragicomedyLesson06,
      ]) {
        expect(
          resolver.positionForStage(lesson: lesson, stage: LessonStage.practice).fen,
          lesson.fen,
        );
        expect(
          resolver.positionForStage(lesson: lesson, stage: LessonStage.prove).fen,
          lesson.fen,
        );
      }
    });

    test('practical warning lessons do not invent key-square overlays', () {
      for (final lesson in <LessonDefinition>[
        pawnTragicomedyLesson05,
        pawnTragicomedyLesson06,
      ]) {
        final overlay = overlayEngine.build(lesson: lesson, fen: lesson.fen);
        expect(overlay.squares, isEmpty);
      }
    });

    test('uses only Learn Practice and Prove roles', () {
      for (final positions in <List<LessonPositionDefinition>>[
        pawnTragicomedyLesson05Positions,
        pawnTragicomedyLesson06Positions,
      ]) {
        expect(
          positions.map((position) => position.role).toSet(),
          <LessonPositionRole>{
            LessonPositionRole.learn,
            LessonPositionRole.practice,
            LessonPositionRole.prove,
          },
        );
      }
    });
  });
}
