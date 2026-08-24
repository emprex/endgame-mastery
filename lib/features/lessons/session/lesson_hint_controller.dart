import '../domain/lesson_hints.dart';

enum LessonHintLevel { none, concept, visual, targeted }

class LessonHintController {
  LessonHintController({required this.hints});

  final LessonHints hints;

  LessonHintLevel _level = LessonHintLevel.none;

  LessonHintLevel get level => _level;

  bool get hasHint => _level != LessonHintLevel.none;

  bool get isFullyRevealed => _level == LessonHintLevel.targeted;

  String? get currentHint {
    return switch (_level) {
      LessonHintLevel.none => null,
      LessonHintLevel.concept => hints.concept,
      LessonHintLevel.visual => hints.visual,
      LessonHintLevel.targeted => hints.targeted,
    };
  }

  void revealNext() {
    _level = switch (_level) {
      LessonHintLevel.none => LessonHintLevel.concept,
      LessonHintLevel.concept => LessonHintLevel.visual,
      LessonHintLevel.visual => LessonHintLevel.targeted,
      LessonHintLevel.targeted => LessonHintLevel.targeted,
    };
  }

  void reset() {
    _level = LessonHintLevel.none;
  }
}
