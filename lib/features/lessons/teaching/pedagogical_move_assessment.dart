import '../../../core/chess/played_move.dart';

/// Curriculum-only assessment of a completed move.
///
/// This is deliberately separate from Stockfish move classification.
///
/// The curriculum may say that a move reinforces a known concept or deserves
/// attention only when a verified teaching rule supports that conclusion.
///
/// Unknown is a first-class result: we prefer not to judge a move rather than
/// invent pedagogical truth.
enum PedagogicalMoveQuality { reinforcesConcept, needsAttention, unknown }

enum PedagogicalAssessmentSource { curriculum }

class PedagogicalMoveAssessment {
  factory PedagogicalMoveAssessment({
    required PlayedMove move,
    required PedagogicalMoveQuality quality,
    required String title,
    required String message,
    required PedagogicalAssessmentSource source,
  }) {
    final normalizedTitle = title.trim();
    final normalizedMessage = message.trim();

    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'Assessment title must not be empty.',
      );
    }

    if (normalizedMessage.isEmpty) {
      throw ArgumentError.value(
        message,
        'message',
        'Assessment message must not be empty.',
      );
    }

    return PedagogicalMoveAssessment._(
      move: move,
      quality: quality,
      title: normalizedTitle,
      message: normalizedMessage,
      source: source,
    );
  }

  const PedagogicalMoveAssessment._({
    required this.move,
    required this.quality,
    required this.title,
    required this.message,
    required this.source,
  });

  final PlayedMove move;
  final PedagogicalMoveQuality quality;

  /// Short learner-facing coaching headline.
  final String title;

  /// Curriculum-grounded coaching explanation.
  final String message;

  final PedagogicalAssessmentSource source;

  bool get isKnown {
    return quality != PedagogicalMoveQuality.unknown;
  }

  bool get reinforcesConcept {
    return quality == PedagogicalMoveQuality.reinforcesConcept;
  }

  bool get needsAttention {
    return quality == PedagogicalMoveQuality.needsAttention;
  }
}
