import 'dart:async';

import 'package:endgame_mastery/core/engine/position_analysis_engine_factory.dart';
import 'package:endgame_mastery/features/coach/application/coach_game_analyzer.dart';
import 'package:endgame_mastery/features/coach/application/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/coach_game_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
import 'package:endgame_mastery/features/coach/domain/imported_game.dart';
import 'package:flutter/material.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({
    super.key,
    this.parser = const PgnGameParser(),
    this.analyzer,
  });

  final PgnGameParser parser;
  final CoachGameAnalyzer? analyzer;

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final TextEditingController _pgnController = TextEditingController();

  late final CoachGameAnalyzer _analyzer;

  ImportedGame? _importedGame;
  CoachGameSide? _selectedSide;
  CoachGameAnalysis? _analysis;

  String? _errorMessage;
  String? _analysisError;

  bool _isAnalyzing = false;
  int _analysisCompleted = 0;
  int _analysisTotal = 0;

  @override
  void initState() {
    super.initState();

    _analyzer = widget.analyzer ??
        CoachGameAnalyzer(
          engine: createPositionAnalysisEngine(),
        );
  }

  @override
  void dispose() {
    _pgnController.dispose();
    unawaited(_analyzer.dispose());
    super.dispose();
  }

  void _importGame() {
    FocusScope.of(context).unfocus();

    try {
      final game = widget.parser.parse(_pgnController.text);

      setState(() {
        _importedGame = game;
        _selectedSide = null;
        _analysis = null;
        _errorMessage = null;
        _analysisError = null;
        _analysisCompleted = 0;
        _analysisTotal = 0;
      });
    } on PgnParseException catch (error) {
      setState(() {
        _importedGame = null;
        _selectedSide = null;
        _analysis = null;
        _errorMessage = error.message;
        _analysisError = null;
      });
    }
  }

  Future<void> _startFullAnalysis() async {
    final game = _importedGame;
    final side = _selectedSide;

    if (game == null || side == null || _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
      _analysisError = null;
      _analysisCompleted = 0;
      _analysisTotal = 0;
    });

    try {
      final analysis = await _analyzer.analyze(
        game: game,
        side: side,
        onProgress: (completed, total) {
          if (!mounted) {
            return;
          }

          setState(() {
            _analysisCompleted = completed;
            _analysisTotal = total;
          });
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _analysis = analysis;
        _isAnalyzing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _analysisError = error.toString();
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 18.0 : 32.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CoachHeader(),
                      const SizedBox(height: 28),
                      _PgnInputCard(
                        controller: _pgnController,
                        errorMessage: _errorMessage,
                        onChanged: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        onAnalyze: _importGame,
                      ),
                      if (_importedGame case final game?) ...[
                        const SizedBox(height: 20),
                        _ImportedGameCard(
                          game: game,
                          selectedSide: _selectedSide,
                          isAnalyzing: _isAnalyzing,
                          progressCompleted: _analysisCompleted,
                          progressTotal: _analysisTotal,
                          analysisError: _analysisError,
                          onSideChanged: (side) {
                            setState(() {
                              _selectedSide = side;
                              _analysis = null;
                              _analysisError = null;
                            });
                          },
                          onStartAnalysis: _startFullAnalysis,
                        ),
                      ],
                      if (_analysis case final analysis?) ...[
                        const SizedBox(height: 20),
                        _AnalysisResultCard(analysis: analysis),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_alt_rounded, size: 28),
            const SizedBox(width: 10),
            Text(
              'Chess Coach',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Paste your game. Understand what happened. Know what to work on next.',
          style: textTheme.headlineMedium?.copyWith(
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Copy a PGN from Chess.com, Lichess, or another chess platform. '
          'The coach will turn the game into a structured analysis focused on '
          'your decisions and development areas.',
          style: textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

class _PgnInputCard extends StatelessWidget {
  const _PgnInputCard({
    required this.controller,
    required this.errorMessage,
    required this.onChanged,
    required this.onAnalyze,
  });

  final TextEditingController controller;
  final String? errorMessage;
  final VoidCallback onChanged;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste your game',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PGN format',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey<String>('coach-pgn-input'),
              controller: controller,
              minLines: 9,
              maxLines: 16,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText:
                    '[Event "..."]\n[White "..."]\n[Black "..."]\n\n1. e4 e5 2. Nf3 ...',
                errorText: errorMessage,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey<String>('coach-analyze-button'),
              onPressed: onAnalyze,
              icon: const Icon(Icons.auto_graph_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('Analyze Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportedGameCard extends StatelessWidget {
  const _ImportedGameCard({
    required this.game,
    required this.selectedSide,
    required this.isAnalyzing,
    required this.progressCompleted,
    required this.progressTotal,
    required this.analysisError,
    required this.onSideChanged,
    required this.onStartAnalysis,
  });

  final ImportedGame game;
  final CoachGameSide? selectedSide;
  final bool isAnalyzing;
  final int progressCompleted;
  final int progressTotal;
  final String? analysisError;
  final ValueChanged<CoachGameSide> onSideChanged;
  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.62);

    return Card(
      key: const ValueKey<String>('coach-imported-game'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded),
                const SizedBox(width: 10),
                Text(
                  'Game imported',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${game.white} vs ${game.black}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('Result ${game.result}', style: TextStyle(color: muted)),
                Text('${game.fullMoveCount} moves', style: TextStyle(color: muted)),
                if (game.event case final event?)
                  Text(event, style: TextStyle(color: muted)),
                if (game.date case final date?)
                  Text(date, style: TextStyle(color: muted)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${game.analysisPositionCount} positions prepared for engine analysis.',
              key: const ValueKey<String>('coach-analysis-position-count'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: muted,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Which side did you play?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<CoachGameSide>(
              key: const ValueKey<String>('coach-side-selector'),
              segments: <ButtonSegment<CoachGameSide>>[
                ButtonSegment<CoachGameSide>(
                  value: CoachGameSide.white,
                  label: Text('White · ${game.white}'),
                ),
                ButtonSegment<CoachGameSide>(
                  value: CoachGameSide.black,
                  label: Text('Black · ${game.black}'),
                ),
              ],
              selected: selectedSide == null
                  ? const <CoachGameSide>{}
                  : <CoachGameSide>{selectedSide!},
              emptySelectionAllowed: true,
              onSelectionChanged: isAnalyzing
                  ? null
                  : (selection) {
                      if (selection.isNotEmpty) {
                        onSideChanged(selection.first);
                      }
                    },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey<String>('coach-start-full-analysis'),
              onPressed: selectedSide == null || isAnalyzing
                  ? null
                  : onStartAnalysis,
              icon: isAnalyzing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isAnalyzing ? 'Analyzing positions…' : 'Start Full Analysis',
                ),
              ),
            ),
            if (isAnalyzing) ...[
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: progressTotal == 0
                    ? null
                    : progressCompleted / progressTotal,
              ),
              const SizedBox(height: 8),
              Text(
                '$progressCompleted / $progressTotal positions',
                style: TextStyle(color: muted),
              ),
            ],
            if (analysisError case final message?) ...[
              const SizedBox(height: 14),
              Text(
                message,
                key: const ValueKey<String>('coach-analysis-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.analysis});

  final CoachGameAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final critical = analysis.largestEvaluationSwings(limit: 5);
    final muted = Colors.white.withValues(alpha: 0.62);

    return Card(
      key: const ValueKey<String>('coach-analysis-result'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded),
                const SizedBox(width: 10),
                Text(
                  'Engine analysis complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${analysis.moves.length} of your moves analyzed.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 22),
            Text(
              'Largest evaluation swings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'These are engine measurements only. Coaching explanations and '
              'development themes are kept separate from Stockfish data.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: muted,
              ),
            ),
            const SizedBox(height: 14),
            if (critical.isEmpty)
              Text(
                'No centipawn comparison is available for this game.',
                style: TextStyle(color: muted),
              )
            else
              ...critical.map(
                (move) => _CriticalMomentRow(move: move),
              ),
          ],
        ),
      ),
    );
  }
}

class _CriticalMomentRow extends StatelessWidget {
  const _CriticalMomentRow({required this.move});

  final CoachMoveAnalysis move;

  @override
  Widget build(BuildContext context) {
    final loss = move.centipawnLoss ?? 0;
    final pawns = (loss / 100).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      move.position.moveLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Engine choice: ${move.before.bestMove.uci}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pawns pawns',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
