import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/curriculum_catalog.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_route_screen.dart';
import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:endgame_mastery/features/progress/domain/lesson_progress.dart';
import 'package:endgame_mastery/features/progress/domain/lesson_progress_repository.dart';
import 'package:flutter/material.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, this.progressRepository});

  final LessonProgressRepository? progressRepository;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late final LessonProgressRepository _progressRepository;

  Map<String, LessonProgress> _progress = const <String, LessonProgress>{};
  late LessonDefinition _continueLesson;

  @override
  void initState() {
    super.initState();

    _continueLesson = curriculum.first;

    _progressRepository =
        widget.progressRepository ??
        SharedPreferencesLessonProgressRepository();

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressRepository.allProgress();
    final lastLessonId = await _progressRepository.lastLessonId();

    LessonDefinition continueLesson = curriculum.first;

    if (lastLessonId != null) {
      for (final lesson in curriculum) {
        if (lesson.id == lastLessonId) {
          continueLesson = lesson;
          break;
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _progress = progress;
      _continueLesson = continueLesson;
    });
  }

  Future<void> _openLesson(LessonDefinition lesson) async {
    final lessonNumber =
        curriculum.indexWhere((candidate) => candidate.id == lesson.id) + 1;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonRouteScreen(
          lesson: lesson,
          lessonNumber: lessonNumber,
          progressRepository: _progressRepository,
        ),
      ),
    );

    await _loadProgress();
  }

  LessonProgress _progressFor(LessonDefinition lesson) {
    return _progress[lesson.id] ??
        LessonProgress(
          lessonId: lesson.id,
          status: LessonProgressStatus.notStarted,
        );
  }

  int get _completedLessonCount {
    return curriculum
        .where((lesson) => _progressFor(lesson).isCompleted)
        .length;
  }

  int get _completionPercentage {
    if (curriculum.isEmpty) {
      return 0;
    }

    return ((_completedLessonCount / curriculum.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final continueLessonNumber =
        curriculum.indexWhere((lesson) => lesson.id == _continueLesson.id) + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: _HomeHeader(
                      lessonCount: curriculum.length,
                      completedLessonCount: _completedLessonCount,
                      completionPercentage: _completionPercentage,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _ContinueCard(
                      lesson: _continueLesson,
                      lessonNumber: continueLessonNumber,
                      progress: _progressFor(_continueLesson),
                      onTap: () => _openLesson(_continueLesson),
                    ),
                  ),
                ),
              ),
            ),
            for (final section in curriculumCatalog)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                      child: _CurriculumSectionView(
                        section: section,
                        progress: _progress,
                        onLessonTap: _openLesson,
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.lessonCount,
    required this.completedLessonCount,
    required this.completionPercentage,
  });

  final int lessonCount;
  final int completedLessonCount;
  final int completionPercentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_stories_rounded, size: 27),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endgame Mastery',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lessonCount verified lessons available',
                    key: const ValueKey<String>('available-lesson-count'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          key: const ValueKey<String>('curriculum-progress-summary'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Your progress',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '$completionPercentage%',
                    key: const ValueKey<String>('completion-percentage'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: lessonCount == 0
                      ? 0
                      : completedLessonCount / lessonCount,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$completedLessonCount of $lessonCount lessons completed',
                  key: const ValueKey<String>('completed-lesson-count'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.lesson,
    required this.lessonNumber,
    required this.progress,
    required this.onTap,
  });

  final LessonDefinition lesson;
  final int lessonNumber;
  final LessonProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actionLabel = switch (progress.status) {
      LessonProgressStatus.completed => 'Review',
      LessonProgressStatus.inProgress => 'Continue',
      LessonProgressStatus.notStarted => 'Start',
    };

    return Material(
      color: const Color(0xFF232323),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        key: const ValueKey<String>('continue-learning-card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;

              final textContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTINUE LEARNING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lesson $lessonNumber',
                    key: const ValueKey<String>('continue-lesson-number'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    key: const ValueKey<String>('continue-lesson-title'),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lesson.objective,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              );

              final action = Container(
                width: compact ? double.infinity : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      actionLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 19,
                    ),
                  ],
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [textContent, const SizedBox(height: 20), action],
                );
              }

              return Row(
                children: [
                  Expanded(child: textContent),
                  const SizedBox(width: 28),
                  action,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurriculumSectionView extends StatelessWidget {
  const _CurriculumSectionView({
    required this.section,
    required this.progress,
    required this.onLessonTap,
  });

  final CurriculumSection section;
  final Map<String, LessonProgress> progress;
  final ValueChanged<LessonDefinition> onLessonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey<String>('curriculum-section-${section.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          section.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 3
                : constraints.maxWidth >= 560
                ? 2
                : 1;

            final spacing = 14.0;

            final cardWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final lesson in section.lessons)
                  SizedBox(
                    width: cardWidth,
                    child: _LessonCard(
                      lesson: lesson,
                      lessonNumber:
                          curriculum.indexWhere(
                            (candidate) => candidate.id == lesson.id,
                          ) +
                          1,
                      progress:
                          progress[lesson.id] ??
                          LessonProgress(
                            lessonId: lesson.id,
                            status: LessonProgressStatus.notStarted,
                          ),
                      onTap: () => onLessonTap(lesson),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.lessonNumber,
    required this.progress,
    required this.onTap,
  });

  final LessonDefinition lesson;
  final int lessonNumber;
  final LessonProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (progress.status) {
      LessonProgressStatus.completed => 'Completed',
      LessonProgressStatus.inProgress => 'In Progress',
      LessonProgressStatus.notStarted => 'Not Started',
    };

    final statusIcon = switch (progress.status) {
      LessonProgressStatus.completed => Icons.check_circle_rounded,
      LessonProgressStatus.inProgress => Icons.play_circle_outline_rounded,
      LessonProgressStatus.notStarted => Icons.circle_outlined,
    };

    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        key: ValueKey<String>('lesson-card-${lesson.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$lessonNumber',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    statusIcon,
                    key: ValueKey<String>('lesson-status-icon-${lesson.id}'),
                    size: 21,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.objective,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.59),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                statusLabel,
                key: ValueKey<String>('lesson-status-${lesson.id}'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
