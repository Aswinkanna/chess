import 'package:chess/chess.dart' as chess;

class AiEngine {
  final chess.Chess board;

  AiEngine(this.board);

  int _evaluateGame(chess.Chess g) {
    int score = 0;
    final pieceValue = {
      'p': 100,
      'n': 320,
      'b': 330,
      'r': 500,
      'q': 900,
      'k': 20000,
    };
    for (final sq in g.board) {
      if (sq == null) continue;
      final val = pieceValue[sq.type] ?? 0;
      score += (sq.color == chess.Color.WHITE) ? val : -val;
    }
    return score;
  }

  Map<String, String>? findBestMove({int depth = 3}) {
    final result = _minimaxRoot(depth, board);
    return result;
  }

  Map<String, String>? _minimaxRoot(int depth, chess.Chess game) {
    final moves = game.generate_moves();
    if (moves.isEmpty) return null;
    int bestScore = -999999;
    Map<String, String>? bestMove;
    for (final m in moves) {
      final fromIdx = m.from as int;
      final toIdx = m.to as int;
      final from = chess.Chess.algebraic(fromIdx);
      final to = chess.Chess.algebraic(toIdx);

      final newGame = chess.Chess.fromFEN(game.fen);
      newGame.move({'from': from, 'to': to});
      final score = _minimax(depth - 1, newGame, -1000000, 1000000, false);
      if (score > bestScore) {
        bestScore = score;
        bestMove = {'from': from, 'to': to};
      }
    }
    return bestMove;
  }

  int _minimax(int depth, chess.Chess game, int alpha, int beta, bool isMax) {
    if (depth == 0 || game.game_over) {
      return _evaluateGame(game);
    }
    final moves = game.generate_moves();
    if (isMax) {
      int maxEval = -999999;
      for (final m in moves) {
        final from = m.from;
        final to = m.to;
        final newGame = chess.Chess.fromFEN(game.fen);
        newGame.move({'from': from, 'to': to});
        final eval = _minimax(depth - 1, newGame, alpha, beta, false);
        if (eval > maxEval) maxEval = eval;
        if (eval > alpha) alpha = eval;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final m in moves) {
        final from = m.from;
        final to = m.to;
        final newGame = chess.Chess.fromFEN(game.fen);
        newGame.move({'from': from, 'to': to});
        final eval = _minimax(depth - 1, newGame, alpha, beta, true);
        if (eval < minEval) minEval = eval;
        if (eval < beta) beta = eval;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }
}
