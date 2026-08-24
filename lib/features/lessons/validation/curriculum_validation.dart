/// One curriculum validation problem.
class CurriculumValidationIssue {
  const CurriculumValidationIssue({
    required this.lessonId,
    required this.message,
  });

  final String lessonId;
  final String message;

  @override
  String toString() {
    return '$lessonId: $message';
  }
}

/// Result of validating one or more curriculum lessons.
class CurriculumValidationResult {
  CurriculumValidationResult({
    Iterable<CurriculumValidationIssue> issues =
        const <CurriculumValidationIssue>[],
  }) : issues = List<CurriculumValidationIssue>.unmodifiable(issues);

  final List<CurriculumValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}
