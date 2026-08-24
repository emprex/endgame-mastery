import '../session/lesson_experience_state.dart';
import '../session/lesson_proof_evaluation.dart';
import '../session/lesson_stage.dart';

/// Semantic primary action exposed to future Flutter lesson widgets.
///
/// This is presentation intent only.
/// Actual session transitions remain owned by LessonSessionController.
enum LessonPrimaryAction {
  startPractice,
  startProve,
  completeLesson,
  nextLesson,
}

/// Read-only Flutter-facing presentation contract.
///
/// It translates LessonExperienceState into stable labels and visibility flags
/// without owning session transitions, gameplay, Stockfish, or chess theory.
class LessonExperiencePresentation {
  const LessonExperiencePresentation({
    required this.stageLabel,
    required this.stageTitle,
    required this.primaryAction,
    required this.primaryActionLabel,
    required this.boardInteractionEnabled,
    required this.showLearnContent,
    required this.learnText,
    required this.hasProofResult,
    required this.proofTitle,
    required this.proofMessage,
    required this.nextAvailable,
    required this.curriculumEnd,
  });

  final String stageLabel;
  final String stageTitle;

  final LessonPrimaryAction? primaryAction;
  final String? primaryActionLabel;

  final bool boardInteractionEnabled;

  final bool showLearnContent;
  final String? learnText;

  final bool hasProofResult;
  final String? proofTitle;
  final String? proofMessage;

  final bool nextAvailable;
  final bool curriculumEnd;
}

/// Converts lesson experience state into UI-ready semantic presentation data.
///
/// Important:
///
/// - no Flutter widgets;
/// - no colors;
/// - no Stockfish;
/// - no chess evaluation;
/// - no session mutation;
/// - no invented theoretical truth.
class LessonExperiencePresenter {
  const LessonExperiencePresenter();

  LessonExperiencePresentation present(LessonExperienceState experience) {
    final stage = experience.stage;

    final proofPresentation = _proofPresentation(experience.proofEvaluation);

    return LessonExperiencePresentation(
      stageLabel: _stageLabel(stage),
      stageTitle: _stageTitle(stage, curriculumEnd: experience.isCurriculumEnd),
      primaryAction: _primaryAction(experience),
      primaryActionLabel: _primaryActionLabel(experience),
      boardInteractionEnabled: _boardInteractionEnabled(stage),
      showLearnContent: stage == LessonStage.learn,
      learnText: stage == LessonStage.learn
          ? experience.lesson.learnText
          : null,
      hasProofResult: experience.hasProofEvaluation,
      proofTitle: proofPresentation?.title,
      proofMessage: proofPresentation?.message,
      nextAvailable: experience.hasNextLesson,
      curriculumEnd: experience.isCurriculumEnd,
    );
  }

  String _stageLabel(LessonStage stage) {
    return switch (stage) {
      LessonStage.learn => 'LEARN',
      LessonStage.practice => 'PRACTICE',
      LessonStage.prove => 'PROVE',
      LessonStage.result => 'RESULT',
      LessonStage.completed => 'NEXT',
    };
  }

  String _stageTitle(LessonStage stage, {required bool curriculumEnd}) {
    return switch (stage) {
      LessonStage.learn => 'Understand the concept',
      LessonStage.practice => 'Explore the position',
      LessonStage.prove => 'Prove it',
      LessonStage.result => 'Your result',
      LessonStage.completed =>
        curriculumEnd ? 'Lesson complete' : 'Ready for the next lesson',
    };
  }

  LessonPrimaryAction? _primaryAction(LessonExperienceState experience) {
    return switch (experience.stage) {
      LessonStage.learn => LessonPrimaryAction.startPractice,
      LessonStage.practice => LessonPrimaryAction.startProve,

      // Prove ends only through an observed legitimate chess result.
      // The presenter must not invent a manual "finish proof" transition.
      LessonStage.prove => null,

      LessonStage.result => LessonPrimaryAction.completeLesson,

      LessonStage.completed =>
        experience.hasNextLesson ? LessonPrimaryAction.nextLesson : null,
    };
  }

  String? _primaryActionLabel(LessonExperienceState experience) {
    return switch (_primaryAction(experience)) {
      LessonPrimaryAction.startPractice => 'Start Practice',
      LessonPrimaryAction.startProve => 'Start Prove',
      LessonPrimaryAction.completeLesson => 'Continue',
      LessonPrimaryAction.nextLesson => 'Next Lesson',
      null => null,
    };
  }

  bool _boardInteractionEnabled(LessonStage stage) {
    return switch (stage) {
      LessonStage.learn => false,
      LessonStage.practice => true,
      LessonStage.prove => true,
      LessonStage.result => false,
      LessonStage.completed => false,
    };
  }

  _ProofPresentation? _proofPresentation(LessonProofEvaluation? evaluation) {
    if (evaluation == null) {
      return null;
    }

    return switch (evaluation.verdict) {
      LessonProofVerdict.passed => const _ProofPresentation(
        title: 'Passed',
        message: 'Your result matches the verified theoretical result.',
      ),
      LessonProofVerdict.failed => const _ProofPresentation(
        title: 'Not yet',
        message: 'Your result did not match the verified theoretical result.',
      ),
      LessonProofVerdict.unsupported => const _ProofPresentation(
        title: 'Unsupported',
        message:
            'This proof position is not covered by verified curriculum theory.',
      ),
    };
  }
}

class _ProofPresentation {
  const _ProofPresentation({required this.title, required this.message});

  final String title;
  final String message;
}
