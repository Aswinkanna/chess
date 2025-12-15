import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import '../services/audio_service.dart';
import '../services/multiplayer_service.dart';

enum PlayerType { human, ai, remote }

class ChessState extends ChangeNotifier {
  chess.Chess board = chess.Chess();
  PlayerType whitePlayer = PlayerType.human;
  PlayerType blackPlayer = PlayerType.ai;
  int aiDepth = 3;
  final AudioService audio = AudioService();
  MultiplayerService? multiplayer;
  StreamSubscription<Map<String, dynamic>?>? _remoteMoveSub;

  String? userId;

  // Move history (SAN strings)
  final List<String> moveHistory = [];

  // room/session info
  String? roomId;
  String localPlayerColor = 'white';

  // Timer (seconds)
  int whiteSeconds = 5 * 60; // default 5 minutes
  int blackSeconds = 5 * 60;
  Timer? _clockTimer;
  bool _clockRunning = false;

  ChessState();

  void resetBoard() {
    board = chess.Chess();
    moveHistory.clear();
    stopClock();
    whiteSeconds = blackSeconds = 5 * 60;
    notifyListeners();
  }

  // returns list of algebraic moves (e.g., ['e4','e5'])
  List<String> legalMovesFrom(String square) {
    final moves = board.generate_moves({'square': square});
    return moves.map((m) => chess.Chess.algebraic(m.to)).toList();
  }

  /// Make a move (synchronous). Returns SAN string if move applied, else null.
  String? makeMove(String from, String to, {bool local = true}) {
    final res = board.move({'from': from, 'to': to});
    if (res == null) return null;
    final san = res.toString();
    moveHistory.add(san);
    // sound: if capture (usually SAN contains 'x') else normal move
    if (san.contains('x')) {
      audio.playCapture();
    } else {
      audio.playMove();
    }
    // multiplayer
    if (multiplayer != null && local && roomId != null) {
      multiplayer!.pushMove(roomId!, {'from': from, 'to': to, 'san': san});
    }
    notifyListeners();
    return san;
  }

  // Undo last move (returns true if undone)
  bool undo() {
    final undone = board.undo();
    if (undone == null) return false;
    if (moveHistory.isNotEmpty) moveHistory.removeLast();
    audio.playMove();
    notifyListeners();
    return true;
  }

  bool get isGameOver => board.game_over;
  String get turn => board.turn == chess.Color.WHITE ? 'white' : 'black';

  void setAILevel(int depth) {
    aiDepth = depth;
    notifyListeners();
  }

  void setPlayers(PlayerType white, PlayerType black) {
    whitePlayer = white;
    blackPlayer = black;
    notifyListeners();
  }

  // ========== Clock methods ==========

  void startClock() {
    if (_clockRunning) return;
    _clockRunning = true;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (board.turn == chess.Color.WHITE) {
        whiteSeconds = (whiteSeconds > 0) ? whiteSeconds - 1 : 0;
      } else {
        blackSeconds = (blackSeconds > 0) ? blackSeconds - 1 : 0;
      }
      if (whiteSeconds == 0 || blackSeconds == 0) {
        // game over by time
        _clockTimer?.cancel();
      }
      notifyListeners();
    });
  }

  void pauseClock() {
    _clockTimer?.cancel();
    _clockRunning = false;
    notifyListeners();
  }

  void stopClock() {
    _clockTimer?.cancel();
    _clockRunning = false;
    notifyListeners();
  }

  void resetClock(int secondsPerSide) {
    stopClock();
    whiteSeconds = secondsPerSide;
    blackSeconds = secondsPerSide;
    notifyListeners();
  }

  // Multiplayer helpers (same as earlier)
  void attachUser(String uid) {
    userId = uid;
  }

  Future<void> startMultiplayerAsHost({
    required String roomId,
    required int bet,
    required String hostUid,
    String hostColor = 'white',
  }) async {
    multiplayer ??= MultiplayerService();
    this.roomId = roomId;
    localPlayerColor = hostColor;
    await multiplayer!.createRoom(
      roomId: roomId,
      hostUid: hostUid,
      bet: bet,
      hostColor: hostColor,
    );
    _listenToRemoteMoves(roomId);
  }

  Future<void> joinMultiplayerRoom({
    required String roomId,
    required String preferColor,
    required String guestUid,
  }) async {
    multiplayer ??= MultiplayerService();
    this.roomId = roomId;
    localPlayerColor = preferColor;
    await multiplayer!.joinRoom(roomId: roomId, guestUid: guestUid, preferColor: preferColor);
    _listenToRemoteMoves(roomId);
  }

  void _listenToRemoteMoves(String roomId) {
    _remoteMoveSub?.cancel();
    _remoteMoveSub = multiplayer?.listenForLastMove(roomId).listen((map) {
      if (map == null) return;
      final from = map['from'] as String?;
      final to = map['to'] as String?;
      if (from == null || to == null) return;
      makeMove(from, to, local: false);
    });
  }

  @override
  void dispose() {
    _remoteMoveSub?.cancel();
    super.dispose();
  }
}
