import 'dart:async';

import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:endgame_mastery/features/progress/domain/lesson_progress_repository.dart';
import 'package:flutter/material.dart';

class LessonRouteScreen extends StatefulWidget {
  const LessonRouteScreen({
    super.key,
    required this.lesson,
    required this.lessonNumber,
    this.progressRepository,
  });

  final LessonDefinition lesson;
  final int lessonNumber;
  final LessonProgressRepository? progressRepository;

  @override
  State<LessonRouteScreen> createState() => _LessonRouteScreenState();
}

class _LessonRouteScreenState extends State<LessonRouteScreen> {
  late final LessonProgressRepository _progressRepository;
  late LessonDefinition _activeLesson;

  int _experienceRevision = 0;

  int get _activeLessonNumber {
    final index = curriculum.indexWhere(
      (lesson) => lesson.id == _activeLesson.id,
    );

    return index >= 0 ? index + 1 : widget.lessonNumber;
  }

  @override
  void initState() {
    super.initState();

    _activeLesson = widget.lesson;

    _progressRepository =
        widget.progressRepository ??
        SharedPreferencesLessonProgressRepository();

    unawaited(_recordLessonOpened(_activeLesson));
  }

  Future<void> _recordLessonOpened(LessonDefinition lesson) async {
    await _progressRepository.setLastLesson(lesson.id);
    await _progressRepository.markInProgress(lesson.id);
  }

  void _onLessonChanged(LessonDefinition lesson) {
    setState(() {
      _activeLesson = lesson;
    });

    unawaited(_recordLessonOpened(lesson));
  }

  void _onLessonCompleted(LessonDefinition lesson) {
    unawaited(_progressRepository.markCompleted(lesson.id));
  }

  void _restartLesson() {
    unawaited(_recordLessonOpened(_activeLesson));

    setState(() {
      _experienceRevision++;
    });
  }

  void _returnToLessons() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Stack(
        children: [
          Positioned.fill(
            child: LessonExperienceScreen(
              key: ValueKey<int>(_experienceRevision),
              initialLesson: _activeLesson,
              onLessonCompleted: _onLessonCompleted,
              onLessonChanged: _onLessonChanged,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: _LessonNavigationBar(
                  lessonNumber: _activeLessonNumber,
                  lessonTitle: _activeLesson.title,
                  onBack: _returnToLessons,
                  onRestart: _restartLesson,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonNavigationBar extends StatelessWidget {
  const _LessonNavigationBar({
    required this.lessonNumber,
    required this.lessonTitle,
    required this.onBack,
    required this.onRestart,
  });

  final int lessonNumber;
  final String lessonTitle;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xF0232323),
                borderRadius: BorderRadius.circular(compact ? 14 : 16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: compact ? 52 : 58,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
                  child: Row(
                    children: [
                      if (compact)
                        IconButton(
                          key: const ValueKey<String>('lesson-back-to-library'),
                          tooltip: 'Lessons',
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      else
                        TextButton.icon(
                          key: const ValueKey<String>('lesson-back-to-library'),
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          label: const Text('Lessons'),
                        ),
                      SizedBox(width: compact ? 2 : 6),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LESSON $lessonNumber',
                              key: const ValueKey<String>(
                                'lesson-route-number',
                              ),
                              style: TextStyle(
                                fontSize: compact ? 9 : 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lessonTitle,
                              key: const ValueKey<String>('lesson-route-title'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: compact ? 2 : 6),
                      IconButton(
                        key: const ValueKey<String>('lesson-restart'),
                        tooltip: 'Restart lesson',
                        onPressed: onRestart,
                        icon: const Icon(Icons.restart_alt_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
