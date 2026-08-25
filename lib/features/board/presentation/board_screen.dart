import 'dart:math' as math;

import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:endgame_mastery/core/chess/board_game_result.dart';
import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/core/engine/engine_factory.dart';
import 'package:endgame_mastery/core/game/game_engine_controller.dart';
import 'package:endgame_mastery/features/board/presentation/chess_board.dart';
import 'package:flutter/material.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    this.initialFen,
    this.engineSide = EngineSide.black,
    this.engineEnabled = true,
    this.engineReplyDelay = const Duration(milliseconds: 1600),
    this.pedagogicalSquares = const <String>{},
    this.onFenChanged,
    this.onGameEnded,
    this.onMovePlayed,
  });

  final String? initialFen;
  final EngineSide engineSide;
  final bool engineEnabled;

  /// Minimum pause after a user move before Stockfish starts its reply.
  ///
  /// This keeps curriculum feedback readable instead of replacing it almost
  /// immediately with the engine move. Engine-first positions are not delayed.
  final Duration engineReplyDelay;

  final Set<String> pedagogicalSquares;
  final ValueChanged<String>? onFenChanged;
  final ValueChanged<BoardGameResult>? onGameEnded;
  final ValueChanged<PlayedMove>? onMovePlayed;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late final ChessController controller;
  late final GameEngineController gameEngineController;

  bool engineReady = false;
  bool waitingBeforeEngineReply = false;
  Object? engineError;

  bool whiteBottom = true;
  String? selectedSquare;
  Set<String> legalTargets = <String>{};
  String? lastFrom;
  String? lastTo;
  bool promotionDialogOpen = false;

  @override
  void initState() {
    super.initState();

    controller = ChessController(fen: widget.initialFen);

    gameEngineController = GameEngineController(
      chessController: controller,
      engine: createChessEngine(),
      engineSide: widget.engineSide,
    );

    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    try {
      await gameEngineController.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        engineReady = true;
        engineError = null;
      });

      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) {
        return;
      }

      await _requestEngineMoveIfNeeded();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        engineError = error;
      });
    }
  }

  @override
  void dispose() {
    gameEngineController.dispose();
    super.dispose();
  }

  void _notifyFenChanged() {
    widget.onFenChanged?.call(controller.fen);
  }

  void _notifyMovePlayed({
    required String from,
    required String to,
    String? promotion,
  }) {
    widget.onMovePlayed?.call(
      PlayedMove(from: from, to: to, promotion: promotion),
    );
  }

  void _notifyGameEndedIfNeeded() {
    final endState = controller.gameEndState();

    switch (endState) {
      case GameEndState.none:
        return;

      case GameEndState.stalemate:
      case GameEndState.draw:
        widget.onGameEnded?.call(BoardGameResult.draw);
        return;

      case GameEndState.checkmate:
        widget.onGameEnded?.call(
          controller.isWhiteToMove()
              ? BoardGameResult.blackWin
              : BoardGameResult.whiteWin,
        );
        return;
    }
  }

  bool get interactionLocked {
    return !widget.engineEnabled ||
        !engineReady ||
        waitingBeforeEngineReply ||
        gameEngineController.engineBusy ||
        gameEngineController.isEngineTurn ||
        controller.isGameOver();
  }

  void clearSelection() {
    if (!mounted) {
      return;
    }

    setState(() {
      selectedSquare = null;
      legalTargets = <String>{};
    });
  }

  void selectSquare(String square) {
    if (promotionDialogOpen || interactionLocked) {
      return;
    }

    if (!controller.canSelect(square)) {
      clearSelection();
      return;
    }

    setState(() {
      selectedSquare = square;
      legalTargets = controller.legalTargets(square);
    });
  }

  void onSquareTap(String square) {
    if (promotionDialogOpen || interactionLocked) {
      return;
    }

    if (selectedSquare == null) {
      selectSquare(square);
      return;
    }

    if (square == selectedSquare) {
      clearSelection();
      return;
    }

    if (legalTargets.contains(square)) {
      attemptMove(from: selectedSquare!, to: square);
      return;
    }

    selectSquare(square);
  }

  Future<void> attemptMove({required String from, required String to}) async {
    if (promotionDialogOpen || interactionLocked) {
      return;
    }

    String? promotion;

    final needsPromotion = controller.isPromotionMove(from: from, to: to);

    if (needsPromotion) {
      promotionDialogOpen = true;

      final piece = controller.pieceVisualAt(from);
      final isWhite = piece?.isWhite ?? true;

      promotion = await _showPromotionDialog(isWhite: isWhite);

      promotionDialogOpen = false;

      if (promotion == null) {
        clearSelection();
        return;
      }
    }

    final moved = gameEngineController.playUserMove(
      from: from,
      to: to,
      promotion: promotion,
    );

    if (!moved || !mounted) {
      return;
    }

    setState(() {
      lastFrom = from;
      lastTo = to;
      selectedSquare = null;
      legalTargets = <String>{};
      engineError = null;
    });

    _notifyMovePlayed(from: from, to: to, promotion: promotion);

    _notifyFenChanged();

    if (controller.isGameOver()) {
      _notifyGameEndedIfNeeded();
      return;
    }

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    await _requestEngineMoveIfNeeded(delayForFeedback: true);
  }

  Future<void> _requestEngineMoveIfNeeded({bool delayForFeedback = false}) async {
    if (!mounted ||
        !widget.engineEnabled ||
        !engineReady ||
        controller.isGameOver() ||
        !gameEngineController.isEngineTurn ||
        gameEngineController.engineBusy) {
      return;
    }

    if (delayForFeedback && widget.engineReplyDelay > Duration.zero) {
      setState(() {
        waitingBeforeEngineReply = true;
      });

      await Future<void>.delayed(widget.engineReplyDelay);

      if (!mounted) {
        return;
      }

      setState(() {
        waitingBeforeEngineReply = false;
      });

      if (!widget.engineEnabled ||
          controller.isGameOver() ||
          !gameEngineController.isEngineTurn ||
          gameEngineController.engineBusy) {
        return;
      }
    }

    final engineFuture = gameEngineController.requestEngineMove();

    setState(() {});

    try {
      final engineMoved = await engineFuture;

      if (!mounted) {
        return;
      }

      if (!engineMoved) {
        setState(() {});
        return;
      }

      final engineMove = gameEngineController.lastEngineMove;

      setState(() {
        lastFrom = engineMove?.from;
        lastTo = engineMove?.to;
        engineError = null;
      });

      if (engineMove != null) {
        _notifyMovePlayed(
          from: engineMove.from,
          to: engineMove.to,
          promotion: engineMove.promotion,
        );
      }

      _notifyFenChanged();
      _notifyGameEndedIfNeeded();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        engineError = error;
      });
    }
  }

  Future<String?> _showPromotionDialog({required bool isWhite}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF2B2932),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose promotion',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _promotionPieceButton(
                        dialogContext: dialogContext,
                        value: 'q',
                        label: 'Queen',
                        piece: isWhite
                            ? WhiteQueen(size: 54)
                            : BlackQueen(size: 54),
                      ),
                      _promotionPieceButton(
                        dialogContext: dialogContext,
                        value: 'r',
                        label: 'Rook',
                        piece: isWhite
                            ? WhiteRook(size: 54)
                            : BlackRook(size: 54),
                      ),
                      _promotionPieceButton(
                        dialogContext: dialogContext,
                        value: 'b',
                        label: 'Bishop',
                        piece: isWhite
                            ? WhiteBishop(size: 54)
                            : BlackBishop(size: 54),
                      ),
                      _promotionPieceButton(
                        dialogContext: dialogContext,
                        value: 'n',
                        label: 'Knight',
                        piece: isWhite
                            ? WhiteKnight(size: 54)
                            : BlackKnight(size: 54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _promotionPieceButton({
    required BuildContext dialogContext,
    required String value,
    required String label,
    required Widget piece,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(dialogContext).pop(value);
        },
        child: Container(
          width: 78,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3742),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              piece,
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetGame() async {
    await gameEngineController.reset();

    if (!mounted) {
      return;
    }

    setState(() {
      selectedSquare = null;
      legalTargets = <String>{};
      lastFrom = null;
      lastTo = null;
      promotionDialogOpen = false;
      waitingBeforeEngineReply = false;
      engineError = null;
    });

    _notifyFenChanged();

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    await _requestEngineMoveIfNeeded();
  }

  String _endTitle() {
    switch (controller.gameEndState()) {
      case GameEndState.checkmate:
        return 'CHECKMATE';
      case GameEndState.stalemate:
        return 'STALEMATE';
      case GameEndState.draw:
        return 'DRAW';
      case GameEndState.none:
        return '';
    }
  }

  String _endSubtitle() {
    switch (controller.gameEndState()) {
      case GameEndState.checkmate:
        return controller.isWhiteToMove() ? 'Black wins' : 'White wins';

      case GameEndState.stalemate:
        return 'No legal moves';

      case GameEndState.draw:
        return 'Game drawn';

      case GameEndState.none:
        return '';
    }
  }

  Widget _gameOverOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.58),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 310),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF26252B),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 34,
                  color: Color(0xFFE8C76A),
                ),
                const SizedBox(height: 10),
                Text(
                  _endTitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _endSubtitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: resetGame,
                    icon: const Icon(Icons.replay),
                    label: const Text('Play again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inCheck = controller.isInCheck();
    final gameOver = controller.isGameOver();

    final String statusText;

    if (engineError != null) {
      statusText = 'Engine error';
    } else if (!engineReady) {
      statusText = 'Preparing engine…';
    } else if (waitingBeforeEngineReply) {
      statusText = 'Review your move…';
    } else if (gameEngineController.engineBusy) {
      statusText = 'Stockfish thinking…';
    } else {
      statusText = controller.turnText();
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact =
                constraints.maxWidth < 700 || constraints.maxHeight < 760;

            final double horizontalPadding = compact ? 10 : 18;

            final double headerHeight = compact ? 78 : 104;

            final double controlsHeight = compact ? 66 : 82;

            final double maxBoardWidth =
                constraints.maxWidth - (horizontalPadding * 2);

            final double maxBoardHeight =
                constraints.maxHeight - headerHeight - controlsHeight;

            final double boardSize = math.max(
              240,
              math.min(maxBoardWidth, math.min(maxBoardHeight, 620)),
            );

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: compact ? 8 : 14),
                  Text(
                    'ENDGAME MASTERY',
                    style: TextStyle(
                      fontSize: compact ? 20 : 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: compact ? 1.0 : 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: compact ? 13 : 15,
                      color: engineError != null
                          ? const Color(0xFFFF8A80)
                          : gameOver
                          ? const Color(0xFFE8C76A)
                          : inCheck
                          ? const Color(0xFFFF8A80)
                          : waitingBeforeEngineReply ||
                                gameEngineController.engineBusy
                          ? const Color(0xFFE8C76A)
                          : Colors.white70,
                      fontWeight:
                          (inCheck ||
                              gameOver ||
                              waitingBeforeEngineReply ||
                              gameEngineController.engineBusy)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 16),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: boardSize,
                        height: boardSize,
                        child: Stack(
                          children: [
                            ChessBoard(
                              whiteBottom: whiteBottom,
                              selectedSquare: selectedSquare,
                              legalTargets: legalTargets,
                              lastFrom: lastFrom,
                              lastTo: lastTo,
                              checkedSquare: controller.checkedKingSquare(),
                              pedagogicalSquares: widget.pedagogicalSquares,
                              pieceVisualAt: controller.pieceVisualAt,
                              canDragPieceAt: (square) {
                                if (interactionLocked) {
                                  return false;
                                }

                                return controller.canSelect(square);
                              },
                              onSquareTap: onSquareTap,
                              onPieceDragStart: selectSquare,
                              onPieceDropped: attemptMove,
                            ),
                            if (gameOver) _gameOverOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 14),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                whiteBottom = !whiteBottom;
                              });
                            },
                            icon: const Icon(Icons.flip),
                            label: const Text('Flip board'),
                          ),
                          OutlinedButton.icon(
                            onPressed: resetGame,
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
