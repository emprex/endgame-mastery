import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:flutter/material.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.whiteBottom,
    required this.selectedSquare,
    required this.legalTargets,
    required this.lastFrom,
    required this.lastTo,
    required this.checkedSquare,
    required this.pieceVisualAt,
    required this.canDragPieceAt,
    required this.onSquareTap,
    required this.onPieceDragStart,
    required this.onPieceDropped,
  });

  final bool whiteBottom;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final String? lastFrom;
  final String? lastTo;
  final String? checkedSquare;

  final BoardPieceVisual? Function(String square) pieceVisualAt;
  final bool Function(String square) canDragPieceAt;

  final void Function(String square) onSquareTap;
  final void Function(String square) onPieceDragStart;

  final Future<void> Function({
    required String from,
    required String to,
  }) onPieceDropped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final squareSize = constraints.maxWidth / 8;

        return Stack(
          children: [
            for (int displayRank = 0;
                displayRank < 8;
                displayRank++)
              for (int displayFile = 0;
                  displayFile < 8;
                  displayFile++)
                _buildSquare(
                  displayRank,
                  displayFile,
                  squareSize,
                ),
          ],
        );
      },
    );
  }

  Widget _buildSquare(
    int displayRank,
    int displayFile,
    double squareSize,
  ) {
    final boardFile =
        whiteBottom
            ? displayFile
            : 7 - displayFile;

    final boardRank =
        whiteBottom
            ? 7 - displayRank
            : displayRank;

    final fileChar =
        String.fromCharCode(
      'a'.codeUnitAt(0) + boardFile,
    );

    final rankNumber = boardRank + 1;
    final square = '$fileChar$rankNumber';

    final isLight =
        (boardFile + boardRank).isOdd;

    final isSelected =
        selectedSquare == square;

    final isLegal =
        legalTargets.contains(square);

    final isLastMove =
        lastFrom == square ||
        lastTo == square;

    final isChecked =
        checkedSquare == square;

    final visual =
        pieceVisualAt(square);

    Color background;

    if (isChecked) {
      background =
          const Color(0xFFD9524F);
    } else if (isSelected) {
      background =
          const Color(0xFFF6F669);
    } else if (isLastMove) {
      background =
          const Color(0xFFCDD26A);
    } else {
      background = isLight
          ? const Color(0xFFE6D3A3)
          : const Color(0xFF769656);
    }

    return Positioned(
      left: displayFile * squareSize,
      top: displayRank * squareSize,
      width: squareSize,
      height: squareSize,
      child: DragTarget<String>(
        onWillAcceptWithDetails:
            (details) {
          return legalTargets
              .contains(square);
        },
        onAcceptWithDetails:
            (details) {
          onPieceDropped(
            from: details.data,
            to: square,
          );
        },
        builder: (
          context,
          candidateData,
          rejectedData,
        ) {
          return GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: () =>
                onSquareTap(square),
            child: ColoredBox(
              color: background,
              child: Stack(
                children: [
                  if (visual != null)
                    Center(
                      child:
                          canDragPieceAt(
                                  square)
                              ? Draggable<String>(
                                  data:
                                      square,
                                  onDragStarted:
                                      () {
                                    onPieceDragStart(
                                        square);
                                  },
                                  feedback:
                                      Material(
                                    color: Colors
                                        .transparent,
                                    child:
                                        _pieceWidget(
                                      visual,
                                      squareSize,
                                    ),
                                  ),
                                  childWhenDragging:
                                      const SizedBox
                                          .shrink(),
                                  child:
                                      _pieceWidget(
                                    visual,
                                    squareSize,
                                  ),
                                )
                              : _pieceWidget(
                                  visual,
                                  squareSize,
                                ),
                    ),

                  if (isLegal)
                    Center(
                      child: Container(
                        width:
                            squareSize *
                                0.23,
                        height:
                            squareSize *
                                0.23,
                        decoration:
                            BoxDecoration(
                          color: Colors.black
                              .withValues(
                            alpha: 0.23,
                          ),
                          shape:
                              BoxShape.circle,
                        ),
                      ),
                    ),

                  if (displayFile == 0)
                    Positioned(
                      left: 4,
                      top: 2,
                      child: Text(
                        '$rankNumber',
                        style: TextStyle(
                          fontSize:
                              squareSize *
                                  0.16,
                          fontWeight:
                              FontWeight.w700,
                          color: isLight
                              ? const Color(
                                  0xFF769656)
                              : const Color(
                                  0xFFE6D3A3),
                        ),
                      ),
                    ),

                  if (displayRank == 7)
                    Positioned(
                      right: 4,
                      bottom: 2,
                      child: Text(
                        fileChar,
                        style: TextStyle(
                          fontSize:
                              squareSize *
                                  0.16,
                          fontWeight:
                              FontWeight.w700,
                          color: isLight
                              ? const Color(
                                  0xFF769656)
                              : const Color(
                                  0xFFE6D3A3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pieceWidget(
    BoardPieceVisual visual,
    double squareSize,
  ) {
    final size =
        squareSize * 0.84;

    if (visual.isWhite) {
      return switch (visual.type) {
        BoardPieceType.king =>
          WhiteKing(size: size),
        BoardPieceType.queen =>
          WhiteQueen(size: size),
        BoardPieceType.rook =>
          WhiteRook(size: size),
        BoardPieceType.bishop =>
          WhiteBishop(size: size),
        BoardPieceType.knight =>
          WhiteKnight(size: size),
        BoardPieceType.pawn =>
          WhitePawn(size: size),
      };
    }

    return switch (visual.type) {
      BoardPieceType.king =>
        BlackKing(size: size),
      BoardPieceType.queen =>
        BlackQueen(size: size),
      BoardPieceType.rook =>
        BlackRook(size: size),
      BoardPieceType.bishop =>
        BlackBishop(size: size),
      BoardPieceType.knight =>
        BlackKnight(size: size),
      BoardPieceType.pawn =>
        BlackPawn(size: size),
    };
  }
}
