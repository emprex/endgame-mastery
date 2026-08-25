import '../data/pawn_endgame_positions.dart';
import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';
import 'lesson_stage.dart';

class LessonPositionResolver {
  const LessonPositionResolver();

  List<LessonPositionDefinition> positionsFor(LessonDefinition lesson) {
    if (lesson.id == keySquaresLesson01Id) {
      return keySquaresLesson01Positions;
    }

    if (lesson.id == keySquaresLesson02Id) {
      return keySquaresLesson02Positions;
    }

    if (lesson.id == keySquaresLesson03Id) {
      return keySquaresLesson03Positions;
    }

    if (lesson.id == keySquaresLesson04Id) {
      return keySquaresLesson04Positions;
    }

    if (lesson.id == pawnTragicomedyLesson05Id) {
      return pawnTragicomedyLesson05Positions;
    }

    if (lesson.id == pawnTragicomedyLesson06Id) {
      return pawnTragicomedyLesson06Positions;
    }

    return <LessonPositionDefinition>[
      LessonPositionDefinition(
        id: '${lesson.id}-default',
        lessonId: lesson.id,
        role: LessonPositionRole.learn,
        fen: lesson.fen,
        theoreticalResult: lesson.theoreticalResult,
      ),
    ];
  }

  List<LessonPositionDefinition> practicePositionsFor(LessonDefinition lesson) {
    return positionsFor(lesson)
        .where((position) => position.role == LessonPositionRole.practice)
        .toList(growable: false);
  }

  LessonPositionDefinition positionForStage({
    required LessonDefinition lesson,
    required LessonStage stage,
    int practiceIndex = 0,
  }) {
    final positions = positionsFor(lesson);

    if (stage == LessonStage.practice) {
      final practice = practicePositionsFor(lesson);

      if (practice.isNotEmpty) {
        final safeIndex = practiceIndex.clamp(0, practice.length - 1);
        return practice[safeIndex];
      }
    }

    final wantedRole = switch (stage) {
      LessonStage.learn => LessonPositionRole.learn,
      LessonStage.practice => LessonPositionRole.practice,
      LessonStage.prove => LessonPositionRole.prove,
      LessonStage.result => LessonPositionRole.prove,
      LessonStage.completed => LessonPositionRole.prove,
    };

    for (final position in positions) {
      if (position.role == wantedRole) {
        return position;
      }
    }

    return positions.first;
  }
}
