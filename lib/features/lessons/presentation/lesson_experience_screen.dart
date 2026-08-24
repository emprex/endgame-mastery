import 'package:endgame_mastery/core/chess/board_game_result.dart';
import 'package:endgame_mastery/features/board/presentation/board_screen.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_presenter.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_completed_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_learn_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_practice_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_prove_panel.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_result_panel.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_builder.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_overlay_policy.dart';
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

  late final LessonSessionController _sessionController;
  late final LessonHintController _hintController;

  late String _currentFen;

  String? _proofFen;

  int _boardRevision = 0;

  @override
  void initState() {
    super.initState();

    _sessionController = LessonSessionController(
      initialState: LessonSessionState.initial(keySquaresLesson01),
    );

    _hintController = LessonHintController(hints: keySquaresLesson01Hints);

    _currentFen = keySquaresLesson01.fen;
  }

  void _startPractice() {
    _hintController.reset();
    _sessionController.startPractice();

    setState(() {});
  }

  void _startProve() {
    _hintController.reset();
    _sessionController.startProve();

    setState(() {
      _currentFen = keySquaresLesson01.fen;
      _proofFen = keySquaresLesson01.fen;
      _boardRevision++;
    });
  }

  void _requestHint() {
    _hintController.revealNext();

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

    setState(() {});
  }

  void _onBoardFenChanged(String fen) {
    if (_currentFen == fen) {
      return;
    }

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

    setState(() {});
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
    );

    final presentation = _presenter.present(experience);

    final showHintKeySquares = _hintOverlayPolicy.showKeySquares(
      _hintController.level,
    );

    final showPedagogicalSquares =
        presentation.showLearnContent || showHintKeySquares;

    final board = IgnorePointer(
      key: const ValueKey<String>('lesson-board-interaction-gate'),
      ignoring: !presentation.boardInteractionEnabled,
      child:
          widget.board ??
          BoardScreen(
            key: ValueKey<int>(_boardRevision),
            pedagogicalSquares: showPedagogicalSquares
                ? experience.teaching.keySquares
                : const <String>{},
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
      );
    } else if (showProvePanel) {
      sidePanel = LessonProvePanel(
        stageLabel: presentation.stageLabel,
        stageTitle: presentation.stageTitle,
        hintText: _hintController.currentHint,
        hintProgressLabel: _hintProgressLabel,
        hintActionLabel: _hintActionLabel,
        onHintRequested: _hintActionLabel == null ? null : _requestHint,
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
        curriculumEnd: presentation.curriculumEnd,
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

        return Stack(
          children: [
            Positioned.fill(child: board),
            if (showLearnPanel)
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
            if (!showLearnPanel && sidePanel != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(child: Center(child: sidePanel)),
                ),
              ),
          ],
        );
      },
    );
  }
}
