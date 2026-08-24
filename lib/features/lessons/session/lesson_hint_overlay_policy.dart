import 'lesson_hint_controller.dart';

/// Decides when pedagogical board geometry may be revealed by hints.
///
/// Concept hints remain textual.
/// Visual and targeted hints may reveal the current pedagogical squares.
class LessonHintOverlayPolicy {
  const LessonHintOverlayPolicy();

  bool showKeySquares(LessonHintLevel level) {
    return switch (level) {
      LessonHintLevel.none => false,
      LessonHintLevel.concept => false,
      LessonHintLevel.visual => true,
      LessonHintLevel.targeted => true,
    };
  }
}
