import '../../../core/chess/played_move.dart';

/// Origin of a move explanation.
///
/// Curriculum explanations are based only on verified teaching knowledge.
///
/// Engine analysis remains explicitly separate and must never be presented
/// as curriculum truth.
enum MoveExplanationSource { curriculum }

/// Pedagogical interpretation of one completed chess move.
///
/// This object does not run Stockfish and does not calculate chess truth.
/// It only transports an explanation produced by a dedicated teaching rule.
class MoveExplanation {
  factory MoveExplanation({
    required PlayedMove move,
    required String title,
    required String message,
    required MoveExplanationSource source,
  }) {
    final normalizedTitle = title.trim();
    final normalizedMessage = message.trim();

    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'Move explanation title must not be empty.',
      );
    }

    if (normalizedMessage.isEmpty) {
      throw ArgumentError.value(
        message,
        'message',
        'Move explanation message must not be empty.',
      );
    }

    return MoveExplanation._(
      move: move,
      title: normalizedTitle,
      message: normalizedMessage,
      source: source,
    );
  }

  const MoveExplanation._({
    required this.move,
    required this.title,
    required this.message,
    required this.source,
  });

  final PlayedMove move;

  /// Short learner-facing heading.
  ///
  /// Example:
  /// "Key-square geometry changed"
  final String title;

  /// Verified pedagogical explanation.
  final String message;

  final MoveExplanationSource source;
}
