import 'lesson_progress.dart';

abstract interface class LessonProgressRepository {
  Future<LessonProgress> progressFor(String lessonId);

  Future<Map<String, LessonProgress>> allProgress();

  Future<String?> lastLessonId();

  Future<void> markInProgress(String lessonId);

  Future<void> markCompleted(String lessonId);

  Future<void> setLastLesson(String lessonId);
}
