import 'package:endgame_mastery/features/board/presentation/board_screen.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_presenter.dart';
import 'package:endgame_mastery/features/lessons/presentation/widgets/lesson_learn_panel.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_builder.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:flutter/material.dart';

class LessonExperienceScreen extends StatefulWidget {
  const LessonExperienceScreen({super.key, this.board});

  /// Test seam only.
  ///
  /// Production uses the real BoardScreen.
  final Widget? board;

  @override
  State<LessonExperienceScreen> createState() => _LessonExperienceScreenState();
}

class _LessonExperienceScreenState extends State<LessonExperienceScreen> {
  static const LessonExperienceBuilder _experienceBuilder =
      LessonExperienceBuilder();

  static const LessonExperiencePresenter _presenter =
      LessonExperiencePresenter();

  late final LessonSessionController _sessionController;

  @override
  void initState() {
    super.initState();

    _sessionController = LessonSessionController(
      initialState: LessonSessionState.initial(keySquaresLesson01),
    );
  }

  void _startPractice() {
    _sessionController.startPractice();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final experience = _experienceBuilder.build(
      session: _sessionController.state,

      // Phase 5.2 still uses the initial verified lesson position.
      //
      // Phase 5.3 will connect live board FEN updates to the lesson
      // experience while Practice is running.
      currentFen: keySquaresLesson01.fen,
    );

    final presentation = _presenter.present(experience);

    final board = IgnorePointer(
      key: const ValueKey<String>('lesson-board-interaction-gate'),
      ignoring: !presentation.boardInteractionEnabled,
      child: widget.board ?? const BoardScreen(),
    );

    final showLearnPanel = presentation.showLearnContent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 900;

        if (wideLayout) {
          return ColoredBox(
            color: const Color(0xFF171717),
            child: Row(
              children: [
                Expanded(child: board),
                if (showLearnPanel)
                  SafeArea(
                    left: false,
                    child: SizedBox(
                      width: 440,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(8, 20, 20, 20),
                        child: LessonLearnPanel(
                          lessonTitle: experience.lesson.title,
                          objective: experience.lesson.objective,
                          learnText: presentation.learnText ?? '',
                          primaryActionLabel:
                              presentation.primaryActionLabel ??
                              'Start Practice',
                          onPrimaryAction: _startPractice,
                        ),
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
                      child: Center(
                        child: LessonLearnPanel(
                          lessonTitle: experience.lesson.title,
                          objective: experience.lesson.objective,
                          learnText: presentation.learnText ?? '',
                          primaryActionLabel:
                              presentation.primaryActionLabel ??
                              'Start Practice',
                          onPrimaryAction: _startPractice,
                        ),
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
