import 'package:endgame_mastery/features/progress/data/shared_preferences_lesson_progress_repository.dart';
import 'package:endgame_mastery/features/progress/domain/lesson_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesLessonProgressRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();

    repository = SharedPreferencesLessonProgressRepository(preferences);
  });

  test('unknown lesson starts as not started', () async {
    final progress = await repository.progressFor('lesson-01');

    expect(progress.status, LessonProgressStatus.notStarted);
  });

  test('lesson can become in progress', () async {
    await repository.markInProgress('lesson-01');

    final progress = await repository.progressFor('lesson-01');

    expect(progress.status, LessonProgressStatus.inProgress);
  });

  test('lesson can become completed', () async {
    await repository.markCompleted('lesson-01');

    final progress = await repository.progressFor('lesson-01');

    expect(progress.status, LessonProgressStatus.completed);
  });

  test('completed lesson is not downgraded to in progress', () async {
    await repository.markCompleted('lesson-01');
    await repository.markInProgress('lesson-01');

    final progress = await repository.progressFor('lesson-01');

    expect(progress.status, LessonProgressStatus.completed);
  });

  test('last opened lesson is persisted', () async {
    await repository.setLastLesson('lesson-03');

    expect(await repository.lastLessonId(), 'lesson-03');
  });

  test('all progress returns stored lesson states', () async {
    await repository.markCompleted('lesson-01');
    await repository.markInProgress('lesson-02');

    final allProgress = await repository.allProgress();

    expect(allProgress['lesson-01']?.status, LessonProgressStatus.completed);

    expect(allProgress['lesson-02']?.status, LessonProgressStatus.inProgress);
  });
}
