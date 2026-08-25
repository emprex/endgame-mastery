import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';

class LessonRouteScreen extends StatefulWidget {
  const LessonRouteScreen({
    super.key,
    required this.lesson,
    required this.lessonNumber,
  });

  final LessonDefinition lesson;
  final int lessonNumber;

  @override
  State<LessonRouteScreen> createState() => _LessonRouteScreenState();
}

class _LessonRouteScreenState extends State<LessonRouteScreen> {
  int _experienceRevision = 0;

  void _restartLesson() {
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
              initialLesson: widget.lesson,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _LessonNavigationBar(
                  lessonNumber: widget.lessonNumber,
                  lessonTitle: widget.lesson.title,
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE6232323),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  key: const ValueKey<String>('lesson-back-to-library'),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: const Text('Lessons'),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LESSON $lessonNumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        lessonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
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
    );
  }
}
