import 'package:endgame_mastery/features/coach/application/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/imported_game.dart';
import 'package:flutter/material.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key, this.parser = const PgnGameParser()});

  final PgnGameParser parser;

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final TextEditingController _pgnController = TextEditingController();

  ImportedGame? _importedGame;
  String? _errorMessage;

  @override
  void dispose() {
    _pgnController.dispose();
    super.dispose();
  }

  void _analyzeGame() {
    FocusScope.of(context).unfocus();

    try {
      final game = widget.parser.parse(_pgnController.text);

      setState(() {
        _importedGame = game;
        _errorMessage = null;
      });
    } on PgnParseException catch (error) {
      setState(() {
        _importedGame = null;
        _errorMessage = error.message;
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
                        onAnalyze: _analyzeGame,
                      ),
                      if (_importedGame case final game?) ...[
                        const SizedBox(height: 20),
                        _ImportedGameCard(game: game),
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
  const _ImportedGameCard({required this.game});

  final ImportedGame game;

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
              'Ready for full analysis.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
