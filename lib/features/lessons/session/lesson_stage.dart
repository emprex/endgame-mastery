/// High-level lifecycle stage of a lesson session.
///
/// This is pure lesson-domain state.
/// It does not know about Flutter widgets, Stockfish, or board rendering.
enum LessonStage { learn, practice, prove, result, completed }
