enum LessonProgressStatus { notStarted, inProgress, completed }

class LessonProgress {
  const LessonProgress({required this.lessonId, required this.status});

  final String lessonId;
  final LessonProgressStatus status;

  bool get hasStarted => status != LessonProgressStatus.notStarted;

  bool get isCompleted => status == LessonProgressStatus.completed;
}
