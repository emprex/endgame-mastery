import 'package:shared_preferences/shared_preferences.dart';

import '../domain/lesson_progress.dart';
import '../domain/lesson_progress_repository.dart';

class SharedPreferencesLessonProgressRepository
    implements LessonProgressRepository {
  SharedPreferencesLessonProgressRepository([this._preferences]);

  static const String _statusPrefix = 'lesson_progress_';
  static const String _lastLessonKey = 'last_lesson_id';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<LessonProgress> progressFor(String lessonId) async {
    final preferences = await _prefs;

    final storedValue = preferences.getString('$_statusPrefix$lessonId');

    return LessonProgress(
      lessonId: lessonId,
      status: _statusFromStorage(storedValue),
    );
  }

  @override
  Future<Map<String, LessonProgress>> allProgress() async {
    final preferences = await _prefs;

    final result = <String, LessonProgress>{};

    for (final key in preferences.getKeys()) {
      if (!key.startsWith(_statusPrefix)) {
        continue;
      }

      final lessonId = key.substring(_statusPrefix.length);

      result[lessonId] = LessonProgress(
        lessonId: lessonId,
        status: _statusFromStorage(preferences.getString(key)),
      );
    }

    return Map<String, LessonProgress>.unmodifiable(result);
  }

  @override
  Future<String?> lastLessonId() async {
    final preferences = await _prefs;

    return preferences.getString(_lastLessonKey);
  }

  @override
  Future<void> markInProgress(String lessonId) async {
    final current = await progressFor(lessonId);

    if (current.isCompleted) {
      return;
    }

    final preferences = await _prefs;

    await preferences.setString(
      '$_statusPrefix$lessonId',
      LessonProgressStatus.inProgress.name,
    );
  }

  @override
  Future<void> markCompleted(String lessonId) async {
    final preferences = await _prefs;

    await preferences.setString(
      '$_statusPrefix$lessonId',
      LessonProgressStatus.completed.name,
    );
  }

  @override
  Future<void> setLastLesson(String lessonId) async {
    final preferences = await _prefs;

    await preferences.setString(_lastLessonKey, lessonId);
  }

  LessonProgressStatus _statusFromStorage(String? value) {
    return switch (value) {
      'inProgress' => LessonProgressStatus.inProgress,
      'completed' => LessonProgressStatus.completed,
      _ => LessonProgressStatus.notStarted,
    };
  }
}
