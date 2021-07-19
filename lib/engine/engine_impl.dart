import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chess/engine/engine.dart';
import 'package:chess/engine/models/square.dart';
import 'package:chess/engine/models/board.dart';

class EngineImpl implements Engine {
  final Board board;
  final AssetsAudioPlayer player;

  const EngineImpl({required this.board, required this.player});

  factory EngineImpl.initialize() {
    return EngineImpl(
      board: Board.createBoard(),
      player: AssetsAudioPlayer.newPlayer(),
    );
  }

  @override
  Board get chessBoard => board;

  @override
  void movePiece(List<int> currentPosition, List<int> targetPosition) {
    if (board.movePiece(currentPosition, targetPosition)) {
      playSound();
    }
  }

  @override
  void playSound() {
    player.open(
      Audio("assets/click.wav"),
    );
  }

  @override
  List<List<Square>> get squares => board.squares;
}
