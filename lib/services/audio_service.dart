import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playMove() async {
    try {
      await _player.play(AssetSource('sounds/move.mp3'));
    } catch (_) {}
  }

  Future<void> playCapture() async {
    try {
      await _player.play(AssetSource('sounds/capture.mp3'));
    } catch (_) {}
  }

  Future<void> playCheck() async {
    try {
      await _player.play(AssetSource('sounds/check.mp3'));
    } catch (_) {}
  }

  Future<void> playGameOver() async {
    try {
      await _player.play(AssetSource('sounds/game_over.mp3'));
    } catch (_) {}
  }
}
