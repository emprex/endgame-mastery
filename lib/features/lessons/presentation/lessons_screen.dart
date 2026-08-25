import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  void _openLesson(BuildContext context, LessonDefinition lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonExperienceScreen(initialLesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171717),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Endgame Mastery',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const Text(
                  'Pawn Endgames',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn the essential ideas one position at a time.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.70),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                for (var index = 0; index < curriculum.length; index++) ...[
                  _LessonCard(
                    index: index,
                    lesson: curriculum[index],
                    onTap: () => _openLesson(context, curriculum[index]),
                  ),
                  if (index < curriculum.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.lesson,
    required this.onTap,
  });

  final int index;
  final LessonDefinition lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF232323),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.objective,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.66),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
