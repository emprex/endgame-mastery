import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_factory.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/features/coach/data/coach_engine_analyzer.dart';
import 'package:endgame_mastery/features/coach/data/game_reconstructor.dart';
import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';
import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/coach_training_prompt.dart';
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
  final CoachTrainingPromptBuilder _trainingPromptBuilder =
      const CoachTrainingPromptBuilder();

  CoachAnalysisPlan? _analysisPlan;
  CoachEngineAnalysisResult? _engineResult;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void dispose() {
    _pgnController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    FocusScope.of(context).unfocus();

    late final CoachAnalysisPlan plan;
    try {
      final game = _parser.parse(_pgnController.text);
      final reconstructedMoves = _reconstructor.reconstruct(game);
      plan = _planner.build(
        game: game,
        reconstructedMoves: reconstructedMoves,
      );
    } on FormatException catch (error) {
      setState(() {
        _analysisPlan = null;
        _engineResult = null;
        _error = error.message.toString();
      });
      return;
    }

    setState(() {
      _analysisPlan = plan;
      _engineResult = null;
      _isAnalyzing = true;
      _error = null;
    });

    ChessEngine? engine;
    try {
      engine = createChessEngine();
      if (engine is! PositionAnalysisEngine) {
        throw UnsupportedError(
          'Full Stockfish position analysis is currently available on Web. The game was imported and validated, but this platform does not yet expose the analysis engine.',
        );
      }

      await engine.initialize();
      final result = await CoachEngineAnalyzer(engine: engine).analyze(
        plan.reconstructedMoves,
      );

      if (!mounted) return;
      setState(() {
        _engineResult = result;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Engine analysis could not complete: $error';
      });
    } finally {
      await engine?.dispose();
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
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
    final engineResult = _engineResult;

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
                  'The coach uses Stockfish to locate the important moments, then turns those moments into explanations and training — not just a list of best moves.',
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
                    hintText:
                        '[White "Player"]\n[Black "Opponent"]\n\n1. d4 d5 2. Nf3 Nf6 ...',
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
                  onPressed: _isAnalyzing ? null : _analyze,
                  icon: _isAnalyzing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology_alt_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _isAnalyzing ? 'ANALYZING GAME…' : 'ANALYZE MY GAME',
                    ),
                  ),
                ),
                if (plan != null) ...[
                  const SizedBox(height: 32),
                  _GameImportedCard(plan: plan),
                ],
                if (_isAnalyzing && plan != null) ...[
                  const SizedBox(height: 20),
                  const _AnalysisProgressCard(),
                ],
                if (engineResult != null) ...[
                  const SizedBox(height: 28),
                  _EngineSummaryCard(result: engineResult),
                  const SizedBox(height: 24),
                  Text(
                    'Critical decisions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'These are engine-detected turning points. The impact tells us where to investigate; it does not, by itself, claim why the decision was made.',
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  if (engineResult.criticalMoments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'No significant engine swing was detected in this scan. Smaller decisions can still contain useful coaching material.',
                        ),
                      ),
                    )
                  else
                    for (final moment in engineResult.criticalMoments)
                      _CriticalMomentCard(
                        analysis: moment,
                        prompt: _trainingPromptBuilder.build(moment),
                      ),
                ],
                if (plan != null && engineResult == null && !_isAnalyzing) ...[
                  const SizedBox(height: 20),
                  Text(
                    'How your coach analyzes it',
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

class _AnalysisProgressCard extends StatelessWidget {
  const _AnalysisProgressCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Stockfish is scanning the reconstructed positions and comparing each played decision with the best available continuation.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineSummaryCard extends StatelessWidget {
  const _EngineSummaryCard({required this.result});

  final CoachEngineAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final critical = result.criticalMoments.length;
    final severe = result.moves
        .where(
          (move) =>
              move.impact == EngineImpactLevel.severe ||
              move.impact == EngineImpactLevel.forcedMateSwing,
        )
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game scan complete',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text('${result.moves.length} decisions checked'),
            Text('$critical critical moments to review'),
            Text('$severe major turning points'),
          ],
        ),
      ),
    );
  }
}

class _CriticalMomentCard extends StatelessWidget {
  const _CriticalMomentCard({
    required this.analysis,
    required this.prompt,
  });

  final CoachMoveEngineAnalysis analysis;
  final CoachTrainingPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final loss = analysis.centipawnLoss;
    final line = prompt.engineLine.take(6).join(' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prompt.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(label: Text(_impactLabel(analysis.impact))),
              ],
            ),
            const SizedBox(height: 10),
            Text('Played: ${prompt.playedMove}'),
            Text('Engine candidate: ${prompt.engineMove}'),
            if (loss != null)
              Text('Engine impact: ${(loss / 100).toStringAsFixed(2)} pawns'),
            if (line.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Principal line: $line',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const Divider(height: 28),
            Text(
              'Coach drill',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(prompt.question),
            const SizedBox(height: 10),
            Text(
              prompt.proofInstruction,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _impactLabel(EngineImpactLevel impact) {
    return switch (impact) {
      EngineImpactLevel.negligible => 'Stable',
      EngineImpactLevel.small => 'Small',
      EngineImpactLevel.significant => 'Significant',
      EngineImpactLevel.severe => 'Severe',
      EngineImpactLevel.forcedMateSwing => 'Mate swing',
      EngineImpactLevel.unclassified => 'Review',
    };
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
