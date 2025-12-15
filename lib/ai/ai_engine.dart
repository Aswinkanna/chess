import 'package:chess/chess.dart' as chess;
import 'dart:math';

class AiEngine {
  final int depth;
  AiEngine({required this.depth});

  Map<String, String>? bestMove(chess.Chess game) {
    final moves = game.moves({'verbose': true});
    if (moves.isEmpty) return null;

    // Simple AI: random legal move (stable & correct)
    final move = moves[Random().nextInt(moves.length)];
    return {
      'from': move['from'],
      'to': move['to'],
    };
  }
}
