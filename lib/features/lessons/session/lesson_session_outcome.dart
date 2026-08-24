/// Actual result achieved by the learner during a Prove session.
///
/// This is observed session data, not curriculum theory.
///
/// It deliberately remains separate from TheoreticalResult:
///
/// - TheoreticalResult = what the verified curriculum says should happen.
/// - LessonSessionOutcome = what actually happened in the played proof.
enum LessonSessionOutcome { win, draw, loss }
