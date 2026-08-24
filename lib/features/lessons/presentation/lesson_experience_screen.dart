import 'package:endgame_mastery/core/chess/board_game_result.dart';
import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/board/presentation/board_screen.dart';
import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_hints.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_presenter.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_completed_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_learn_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_result_panel.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_builder.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_overlay_policy.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_move_explanation_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_progression.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter/material.dart';

class LessonExperienceScreen extends StatefulWidget {
  const LessonExperienceScreen({super.key, this.board});

  final Widget? board;

  @override
  State<LessonExperienceScreen> createState() => _LessonExperienceScreenState();
}

class _LessonExperienceScreenState extends State<LessonExperienceScreen> {
  static const LessonExperienceBuilder _experienceBuilder =
      LessonExperienceBuilder();

  static const LessonExperiencePresenter _presenter =
      LessonExperiencePresenter();

  static const LessonHintOverlayPolicy _hintOverlayPolicy =
      LessonHintOverlayPolicy();

  late final LessonProgression _progression;

  late LessonDefinition _currentLesson;
  late LessonSessionController _sessionController;
  late LessonHintController _hintController;
  late LessonMoveExplanationController _moveExplanationController;

  late String _currentFen;

  String? _proofFen;

  int _boardRevision = 0;

  bool _mobilePanelExpanded = true;

  @override
  void initState() {
    super.initState();

    _progression = LessonProgression(curriculum);

    _loadLesson(_progression.firstLesson, rebuild: false);
  }

  LessonHints _hintsForLesson(LessonDefinition lesson) {
    if (lesson.id == keySquaresLesson01.id) {
      return keySquaresLesson01Hints;
    }

    if (lesson.id == keySquaresLesson02.id) {
      return keySquaresLesson02Hints;
    }

    throw StateError('No hints configured for lesson ${lesson.id}.');
  }

  void _loadLesson(
    LessonDefinition lesson, {
    required bool rebuild,
  }) {
    _currentLesson = lesson;

    _sessionController = LessonSessionController(
      initialState: LessonSessionState.initial(lesson),
    );

    _hintController = LessonHintController(
      hints: _hintsForLesson(lesson),
    );

    _moveExplanationController = LessonMoveExplanationController(
      lesson: lesson,
      initialFen: lesson.fen,
    );

    _currentFen = lesson.fen;
    _proofFen = null;
    _mobilePanelExpanded = true;
    _boardRevision++;

    if (rebuild) {
      setState(() {});
    }
  }

  void _startPractice() {
    _hintController.reset();

    _moveExplanationController.reset(_currentLesson.fen);

    _sessionController.startPractice();

    setState(() {
      _mobilePanelExpanded = false;
    });
  }

  void _startProve() {
    _hintController.reset();

    _moveExplanationController.reset(_currentLesson.fen);

    _sessionController.startProve();

    setState(() {
      _currentFen = _currentLesson.fen;
      _proofFen = _currentLesson.fen;
      _mobilePanelExpanded = false;
      _boardRevision++;
    });
  }

  void _requestHint() {
    _hintController.revealNext();

    setState(() {});
  }

  void _onBoardMovePlayed(PlayedMove move) {
    _moveExplanationController.onMovePlayed(move);

    setState(() {});
  }

  String? get _hintActionLabel {
    return switch (_hintController.level) {
      LessonHintLevel.none => 'Get a hint',
      LessonHintLevel.concept => 'Show visual hint',
      LessonHintLevel.visual => 'Show targeted hint',
      LessonHintLevel.targeted => null,
    };
  }

  String? get _hintProgressLabel {
    return switch (_hintController.level) {
      LessonHintLevel.none => null,
      LessonHintLevel.concept => 'Hint 1 of 3',
      LessonHintLevel.visual => 'Hint 2 of 3',
      LessonHintLevel.targeted => 'Hint 3 of 3',
    };
  }

  void _completeLesson() {
    _sessionController.completeLesson();

    setState(() {
      _mobilePanelExpanded = true;
    });
  }

  void _openNextLesson() {
    final nextLesson = _progression.nextLessonFor(_sessionController.state);

    if (nextLesson == null) {
      return;
    }

    _loadLesson(nextLesson, rebuild: true);
  }

  void _onBoardFenChanged(String fen) {
    if (_currentFen == fen) {
      return;
    }

    _moveExplanationController.onFenChanged(fen);

    setState(() {
      _currentFen = fen;
    });
  }

  void _onBoardGameEnded(BoardGameResult result) {
    if (_sessionController.state.stage != LessonStage.prove) {
      return;
    }

    final outcome = switch (result) {
      BoardGameResult.whiteWin => LessonSessionOutcome.win,
      BoardGameResult.blackWin => LessonSessionOutcome.loss,
      BoardGameResult.draw => LessonSessionOutcome.draw,
    };

    _sessionController.completeProof(outcome);

    setState(() {
      _mobilePanelExpanded = true;
    });
  }

  void _toggleMobilePanel() {
    setState(() {
      _mobilePanelExpanded = !_mobilePanelExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = _sessionController.state.stage;

    final experience = _experienceBuilder.build(
      session: _sessionController.state,
      currentFen: _currentFen,
      proofFen: stage == LessonStage.result || stage == LessonStage.completed
          ? _proofFen
          : null,
      progression: stage == LessonStage.completed ? _progression : null,
    );

    final presentation = _presenter.present(experience);

    final hintStageSupportsOverlays =
        stage == LessonStage.practice || stage == LessonStage.prove;

    final showHintKeySquares =
        hintStageSupportsOverlays &&
        _hintOverlayPolicy.showKeySquares(_hintController.level);

    final showPedagogicalSquares =
        presentation.showLearnContent || showHintKeySquares;

    final explanation = _moveExplanationController.latestExplanation;

    final assessment = _moveExplanationController.latestAssessment;

    final board = IgnorePointer(
      key: const ValueKey<String>('lesson-board-interaction-gate'),
      ignoring: !presentation.boardInteractionEnabled,
      child:
          widget.board ??
          BoardScreen(
            key: ValueKey<int>(_boardRevision),
            initialFen: _currentLesson.fen,
            pedagogicalSquares: showPedagogicalSquares
                ? experience.teaching.keySquares
                : const <String>{},
            onMovePlayed: _onBoardMovePlayed,
            onFenChanged: _onBoardFenChanged,
            onGameEnded: _onBoardGameEnded,
          ),
    );

    final showLearnPanel = presentation.showLearnContent;
    final showPracticePanel = experience.stage == LessonStage.practice;
    final showProvePanel = experience.stage == LessonStage.prove;
    final showResultPanel = experience.stage == LessonStage.result;
    final showCompletedPanel = experience.stage == LessonStage.completed;

    Widget? sidePanel;

    if (showLearnPanel) {
      sidePanel = LessonLearnPanel(
        lessonTitle: experience.lesson.title,
        objective: experience.lesson.objective,
        learnText: presentation.learnText ?? '',
        primaryActionLabel: presentation.primaryActionLabel ?? 'Start Practice',
        onPrimaryAction: _startPractice,
      );
    } else if (showPracticePanel) {
      sidePanel = LessonPracticePanel(
        lessonTitle: experience.lesson.title,
        objective: experience.lesson.objective,
        primaryActionLabel: presentation.primaryActionLabel ?? 'Start Prove',
        onPrimaryAction: _startProve,
        hintText: _hintController.currentHint,
        hintProgressLabel: _hintProgressLabel,
        hintActionLabel: _hintActionLabel,
        onHintRequested: _hintActionLabel == null ? null : _requestHint,
        explanationTitle: explanation?.title,
        explanationMessage: explanation?.message,
        assessmentTitle: assessment?.title,
        assessmentMessage: assessment?.message,
      );
    } else if (showProvePanel) {
      sidePanel = LessonProvePanel(
        stageLabel: presentation.stageLabel,
        stageTitle: presentation.stageTitle,
        hintText: _hintController.currentHint,
        hintProgressLabel: _hintProgressLabel,
        hintActionLabel: _hintActionLabel,
        onHintRequested: _hintActionLabel == null ? null : _requestHint,
        explanationTitle: explanation?.title,
        explanationMessage: explanation?.message,
        assessmentTitle: assessment?.title,
        assessmentMessage: assessment?.message,
      );
    } else if (showResultPanel) {
      sidePanel = LessonResultPanel(
        resultTitle: presentation.proofTitle ?? 'Result',
        resultMessage: presentation.proofMessage ?? '',
        primaryActionLabel: presentation.primaryActionLabel ?? 'Continue',
        onPrimaryAction: _completeLesson,
      );
    } else if (showCompletedPanel) {
      sidePanel = LessonCompletedPanel(
        lessonTitle: experience.lesson.title,
        curriculumEnd: experience.isCurriculumEnd,
        primaryActionLabel: experience.hasNextLesson ? 'Next Lesson' : null,
        onPrimaryAction: experience.hasNextLesson ? _openNextLesson : null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 900;

        if (wideLayout) {
          return ColoredBox(
            color: const Color(0xFF171717),
            child: Row(
              children: [
                Expanded(child: board),
                if (sidePanel != null)
                  SafeArea(
                    left: false,
                    child: SizedBox(
                      width: showPracticePanel || showProvePanel ? 380 : 440,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
                        child: sidePanel,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        if (showLearnPanel) {
          return Stack(
            children: [
              Positioned.fill(child: board),
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xE8171717),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Center(child: sidePanel),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: board),

            if (!_mobilePanelExpanded && sidePanel != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: FilledButton.tonalIcon(
                      key: const ValueKey<String>('mobile-coach-open'),
                      onPressed: _toggleMobilePanel,
                      icon: const Icon(Icons.school_outlined),
                      label: Text(
                        showProvePanel
                            ? 'Open Prove panel'
                            : showPracticePanel
                                ? 'Open Coach'
                                : 'Open lesson panel',
                      ),
                    ),
                  ),
                ),
              ),

            if (_mobilePanelExpanded && sidePanel != null)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.48,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 6, 6, 2),
                            child: Row(
                              children: [
                                const Spacer(),
                                Container(
                                  width: 42,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  key: const ValueKey<String>(
                                    'mobile-coach-close',
                                  ),
                                  tooltip: 'Hide panel',
                                  onPressed: _toggleMobilePanel,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Center(child: sidePanel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
