import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess/chess.dart' as chess;
import '../models/chess_state.dart';
import 'tile.dart';
import 'dart:ui' show lerpDouble;
import '../theme/app_theme.dart';
class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> with SingleTickerProviderStateMixin {
  String? selectedSquare;
  Set<String> targetSquares = {};
  static const files = ['a','b','c','d','e','f','g','h'];

  // keys to measure tiles
  final Map<String, GlobalKey> _tileKeys = {};

  // Overlay animation controller
  OverlayEntry? _animEntry;
  AnimationController? _animController;
  Animation<Offset>? _animTween;
  Timer? _clearSelectionTimer;

  @override
  void initState() {
    super.initState();
    // prepare keys for all squares
    for (var f in files) {
      for (int r = 1; r <= 8; r++) {
        _tileKeys['$f$r'] = GlobalKey();
      }
    }
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  }

  @override
  void dispose() {
    _animController?.dispose();
    _animEntry?.remove();
    _clearSelectionTimer?.cancel();
    super.dispose();
  }

  Color _tileColor(int rank, int fileIndex) {
    final dark = AppTheme.boardDark;
    final light = AppTheme.boardLight;
    return (rank + fileIndex) % 2 == 0 ? light : dark;
  }

  String _typeKeyFrom(dynamic piece) {
    if (piece == null) return '';
    final t = piece.type;
    if (t is String) return t;
    try {
      final name = (t as dynamic).name ?? t.toString();
      final n = name.toLowerCase();
      if (n.contains('king')) return 'k';
      if (n.contains('queen')) return 'q';
      if (n.contains('rook')) return 'r';
      if (n.contains('bishop')) return 'b';
      if (n.contains('knight')) return 'n';
      if (n.contains('pawn')) return 'p';
      return n.isNotEmpty ? n[0] : '';
    } catch (_) {
      return t.toString();
    }
  }

  String? _symbolForPiece(dynamic piece) {
    if (piece == null) return null;
    final isWhite = piece.color == chess.Color.WHITE;
    final key = _typeKeyFrom(piece);
    switch (key) {
      case 'k': return isWhite ? '♔' : '♚';
      case 'q': return isWhite ? '♕' : '♛';
      case 'r': return isWhite ? '♖' : '♜';
      case 'b': return isWhite ? '♗' : '♝';
      case 'n': return isWhite ? '♘' : '♞';
      case 'p': return isWhite ? '♙' : '♟';
      default: return null;
    }
  }

  void _computeTargets(ChessState state, String square) {
    final moves = state.legalMovesFrom(square);
    setState(() {
      targetSquares = Set.from(moves);
      selectedSquare = square;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedSquare = null;
      targetSquares.clear();
    });
  }

  Future<void> _animateAndMakeMove(String from, String to, String pieceSymbol) async {
    // get RenderBox for source and dest
    final fromKey = _tileKeys[from];
    final toKey = _tileKeys[to];
    if (fromKey == null || toKey == null) {
      // fallback: perform move without animation
      final san = Provider.of<ChessState>(context, listen: false).makeMove(from, to);
      return;
    }
    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (fromBox == null || toBox == null || overlay == null) {
      final san = Provider.of<ChessState>(context, listen: false).makeMove(from, to);
      return;
    }

    final fromPos = fromBox.localToGlobal(Offset.zero);
    final toPos = toBox.localToGlobal(Offset.zero);
    final size = fromBox.size;

    // Create animation overlay entry
    final entry = OverlayEntry(builder: (context) {
      return AnimatedBuilder(
        animation: _animController!,
        builder: (context, child) {
          final t = _animController!.value;
          final dx = lerpDouble(fromPos.dx, toPos.dx, t)!;
          final dy = lerpDouble(fromPos.dy, toPos.dy, t)!;
          return Positioned(
            left: dx,
            top: dy,
            width: size.width,
            height: size.height,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Text(pieceSymbol, style: TextStyle(fontSize: size.width * 0.9)),
              ),
            ),
          );
        },
      );
    });

    _animEntry = entry;
    overlay.insert(entry);
    // run animation
    await _animController!.forward(from: 0.0);
    _animController!.value = 0.0;
    _animEntry?.remove();
    _animEntry = null;

    // finally perform the move in state
    Provider.of<ChessState>(context, listen: false).makeMove(from, to);
    _clearSelection();
  }

  // helper to format seconds -> mm:ss
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ChessState>(context);

    // Build board inside a Stack so overlay animation can measure tiles
    return Column(
      children: [
        // Board
        Expanded(
          child: LayoutBuilder(builder: (ctx, constraints) {
            final boardSize = constraints.biggest.shortestSide;
            final tileSize = boardSize / 8;
            return Center(
              child: SizedBox(
                width: tileSize * 8,
                height: tileSize * 8,
                child: Stack(
                  children: [
                    // Grid of tiles
                    Positioned.fill(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 64,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemBuilder: (ctx, idx) {
                          final row = 7 - (idx ~/ 8);
                          final col = idx % 8;
                          final squareName = '${files[col]}${row+1}';
                          final piece = state.board.get(squareName);
                          final symbol = _symbolForPiece(piece);
                          final tileIsLight = _tileColor(row + 1, col) == AppTheme.boardLight;
                          final symbolColor = symbol == null ? null : (tileIsLight ? Colors.black : Colors.white);
                          final isSelected = selectedSquare == squareName;
                          final isTarget = targetSquares.contains(squareName);

                          // Tile container with key for measuring
                          return Container(
                            key: _tileKeys[squareName],
                            child: DragTarget<String>(
                              onWillAccept: (fromSquare) {
                                if (fromSquare == null) return false;
                                return state.legalMovesFrom(fromSquare).contains(squareName);
                              },
                              onAccept: (fromSquare) {
                                // animate then move
                                final sym = _symbolForPiece(state.board.get(fromSquare)) ?? '♙';
                                _animateAndMakeMove(fromSquare, squareName, sym);
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Tile(
                                  color: _tileColor(row + 1, col),
                                  highlight: isSelected,
                                  isMoveTarget: isTarget,
                                  onTap: () {
                                    setState(() {
                                      if (selectedSquare == null) {
                                        if (piece != null) _computeTargets(state, squareName);
                                      } else {
                                        if (isTarget && selectedSquare != null) {
                                          // animate and make move
                                          final sym = _symbolForPiece(state.board.get(selectedSquare!)) ?? '♙';
                                          _animateAndMakeMove(selectedSquare!, squareName, sym);
                                        }
                                        _clearSelection();
                                      }
                                    });
                                  },
                                  child: Center(
                                    child: symbol != null
                                        ? LongPressDraggable<String>(
                                            data: squareName,
                                            dragAnchorStrategy: pointerDragAnchorStrategy,
                                            feedback: Material(
                                              color: Colors.transparent,
                                              child: Text(symbol, style: TextStyle(fontSize: tileSize * 0.9)),
                                            ),
                                            childWhenDragging: Opacity(
                                              opacity: 0.2,
                                              child: Text(symbol, style: TextStyle(fontSize: tileSize * 0.9, color: symbolColor)),
                                            ),
                                            onDragStarted: () {
                                              _computeTargets(state, squareName);
                                            },
                                            onDraggableCanceled: (_, __) {
                                              _clearSelection();
                                            },
                                            onDragEnd: (_) {
                                              _clearSelection();
                                            },
                                            child: Text(symbol, style: TextStyle(fontSize: tileSize * 0.9, color: symbolColor)),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Optionally, you could overlay extra UI here
                  ],
                ),
              ),
            );
          }),
        ),

        // Bottom controls: clocks, undo, move history
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.chip,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Clocks & controls
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('White: ${_formatTime(state.whiteSeconds)}', style: const TextStyle(fontSize: 14)),
                  Text('Black: ${_formatTime(state.blackSeconds)}', style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  state.startClock();
                },
                child: const Text('Start'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  state.pauseClock();
                },
                child: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  state.undo();
                },
                child: const Text('Undo'),
              ),

              const Spacer(),

              // Move history condensed (last 6 moves)
              SizedBox(
                width: 320,
                height: 80,
                child: _MoveHistoryWidget(history: state.moveHistory),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoveHistoryWidget extends StatelessWidget {
  final List<String> history;
  const _MoveHistoryWidget({required this.history});

  @override
  Widget build(BuildContext context) {
    final pares = <String>[];
    for (int i = 0; i < history.length; i += 2) {
      final moveNum = (i ~/ 2) + 1;
      final whiteMove = history[i];
      final blackMove = (i + 1) < history.length ? history[i + 1] : '';
      pares.add('$moveNum. $whiteMove ${blackMove.isNotEmpty ? blackMove : ''}');
    }

    return ListView.builder(
      itemCount: pares.length,
      itemBuilder: (ctx, idx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(pares[idx], style: const TextStyle(fontSize: 14)),
        );
      },
    );
  }
}
