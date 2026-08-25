import '../domain/lesson_definition.dart';
import 'curriculum.dart';

class CurriculumSection {
  const CurriculumSection({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final List<LessonDefinition> lessons;
}

/// Product-facing organization of the verified curriculum.
///
/// Lesson theory continues to live in the lesson definitions themselves.
/// This catalog only groups lessons for navigation and presentation.
final List<CurriculumSection> curriculumCatalog =
    List<CurriculumSection>.unmodifiable(<CurriculumSection>[
      CurriculumSection(
        id: 'pawn-endgames',
        title: 'Pawn Endgames',
        description:
            'Master the essential king-and-pawn ideas through exact positions.',
        lessons: curriculum,
      ),
    ]);
