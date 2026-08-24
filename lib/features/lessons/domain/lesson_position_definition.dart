import 'lesson_definition.dart';

enum LessonPositionRole { learn, practice, prove, challenge }

class LessonPositionDefinition {
  factory LessonPositionDefinition({
    required String id,
    required String lessonId,
    required LessonPositionRole role,
    required String fen,
    required TheoreticalResult theoreticalResult,
    String? teachingPoint,
  }) {
    final normalizedId = id.trim();
    final normalizedLessonId = lessonId.trim();
    final normalizedFen = fen.trim();
    final normalizedTeachingPoint = teachingPoint?.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Position id must not be empty.');
    }

    if (normalizedLessonId.isEmpty) {
      throw ArgumentError.value(
        lessonId,
        'lessonId',
        'Lesson id must not be empty.',
      );
    }

    LessonDefinition.validateFen(normalizedFen);

    return LessonPositionDefinition._(
      id: normalizedId,
      lessonId: normalizedLessonId,
      role: role,
      fen: normalizedFen,
      theoreticalResult: theoreticalResult,
      teachingPoint:
          normalizedTeachingPoint == null || normalizedTeachingPoint.isEmpty
          ? null
          : normalizedTeachingPoint,
    );
  }

  const LessonPositionDefinition._({
    required this.id,
    required this.lessonId,
    required this.role,
    required this.fen,
    required this.theoreticalResult,
    required this.teachingPoint,
  });

  final String id;
  final String lessonId;
  final LessonPositionRole role;
  final String fen;
  final TheoreticalResult theoreticalResult;
  final String? teachingPoint;

  ChessSide get sideToMove {
    final fields = fen.split(RegExp(r'\s+'));

    return fields[1] == 'w' ? ChessSide.white : ChessSide.black;
  }
}
