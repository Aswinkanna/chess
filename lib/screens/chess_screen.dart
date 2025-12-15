import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_state.dart';
import '../widgets/chess_board_widget.dart';
import '../services/ai_engine.dart';

class ChessScreen extends StatefulWidget {
  final bool singlePlayer;
  final bool online;
  final String? roomId;
  final bool host;
  final int bet;
  final String? localColor;
  final String? userId;

  const ChessScreen({
    super.key,
    this.singlePlayer = true,
    this.online = false,
    this.roomId,
    this.host = false,
    this.bet = 0,
    this.localColor,
    this.userId,
  });

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  AiEngine? ai;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = Provider.of<ChessState>(context, listen: false);
    if (widget.singlePlayer) {
      ai = AiEngine(state.board);
    }

    // attach user for online matches
    if (widget.userId != null) {
      state.attachUser(widget.userId!);
    }

    if (widget.online && widget.roomId != null) {
      // configure players based on chosen color
      final localColor = widget.localColor ?? 'white';
      state.setPlayers(
        localColor == 'white' ? PlayerType.human : PlayerType.remote,
        localColor == 'black' ? PlayerType.human : PlayerType.remote,
      );
      if (widget.host) {
        state.startMultiplayerAsHost(
          roomId: widget.roomId!,
          bet: widget.bet,
          hostUid: widget.userId ?? 'host',
          hostColor: localColor,
        );
      } else {
        state.joinMultiplayerRoom(
          roomId: widget.roomId!,
          preferColor: localColor,
          guestUid: widget.userId ?? 'guest',
        );
      }
    }
  }

  Future<void> maybeDoAiMove() async {
    final state = Provider.of<ChessState>(context, listen: false);
    if (!widget.singlePlayer) return;
    // if it's AI turn
    final isAiTurn = (state.turn == 'black' && state.blackPlayer == PlayerType.ai) ||
                     (state.turn == 'white' && state.whitePlayer == PlayerType.ai);
    if (isAiTurn && !state.isGameOver) {
      final engine = AiEngine(state.board);
      final best = engine.findBestMove(depth: state.aiDepth);
      if (best != null) {
        state.makeMove(best['from']!, best['to']!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ChessState>(context);
    // after each rebuild, check for AI move
    WidgetsBinding.instance.addPostFrameCallback((_) => maybeDoAiMove());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              state.resetBoard();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: const ChessBoardWidget()),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.isGameOver ? 'Game Over' : 'Turn: ${state.turn}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
