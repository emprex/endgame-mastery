import 'package:endgame_mastery/features/coach/data/game_reconstructor.dart';
import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';
import 'package:endgame_mastery/features/lessons/presentation/lessons_screen.dart';
import 'package:flutter/material.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final TextEditingController _pgnController = TextEditingController();
  final PgnGameParser _parser = const PgnGameParser();
  final GameReconstructor _reconstructor = const GameReconstructor();
  final CoachAnalysisPlanner _planner = const CoachAnalysisPlanner();

  CoachAnalysisPlan? _analysisPlan;
  String? _error;

  @override
  void dispose() {
    _pgnController.dispose();
    super.dispose();
  }

  void _analyze() {
    FocusScope.of(context).unfocus();

    try {
      final game = _parser.parse(_pgnController.text);
      final reconstructedMoves = _reconstructor.reconstruct(game);
      setState(() {
        _analysisPlan = _planner.build(
          game: game,
          reconstructedMoves: reconstructedMoves,
        );
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _analysisPlan = null;
        _error = error.message.toString();
      });
    }
  }

  void _openTrainingLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LessonsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _analysisPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Coach'),
        actions: [
          TextButton.icon(
            onPressed: _openTrainingLibrary,
            icon: const Icon(Icons.school_outlined),
            label: const Text('Training'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              children: [
                Text(
                  'Paste a game. Understand your decisions.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The coach will use engine analysis to locate the important moments, then turn them into explanations, development areas and training — not just a list of best moves.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _pgnController,
                  minLines: 10,
                  maxLines: 18,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Paste Chess.com, Lichess or PGN moves',
                    alignLabelWithHint: true,
                    hintText: '[White "Player"]\n[Black "Opponent"]\n\n1. d4 d5 2. Nf3 Nf6 ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _analyze,
                  icon: const Icon(Icons.psychology_alt_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('ANALYZE MY GAME'),
                  ),
                ),
                if (plan != null) ...[
                  const SizedBox(height: 32),
                  _GameImportedCard(plan: plan),
                  const SizedBox(height: 20),
                  Text(
                    'How your coach will analyze it',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < plan.steps.length; index++)
                    _AnalysisStepTile(
                      number: index + 1,
                      step: plan.steps[index],
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The full game has been legally reconstructed position by position. The next engine layer will score those positions and populate the critical moments without inventing chess conclusions.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameImportedCard extends StatelessWidget {
  const _GameImportedCard({required this.plan});

  final CoachAnalysisPlan plan;

  @override
  Widget build(BuildContext context) {
    final game = plan.game;
    final whiteRating = game.whiteElo == null ? '' : ' (${game.whiteElo})';
    final blackRating = game.blackElo == null ? '' : ' (${game.blackElo})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline),
                const SizedBox(width: 10),
                Text(
                  'Game imported and validated',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${game.white}$whiteRating  vs  ${game.black}$blackRating'),
            const SizedBox(height: 6),
            Text(
              '${game.result} · ${game.fullMoveCount} moves · ${plan.reconstructedMoves.length} positions reconstructed',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            Text(
              game.moves.take(12).join('  '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisStepTile extends StatelessWidget {
  const _AnalysisStepTile({
    required this.number,
    required this.step,
  });

  final int number;
  final CoachAnalysisStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('$number')),
        title: Text(step.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(step.purpose),
        ),
      ),
    );
  }
}
