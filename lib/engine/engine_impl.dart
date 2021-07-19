import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chess/engine/engine.dart';
import 'package:chess/engine/models/square.dart';
import 'package:chess/engine/models/board.dart';

///Chess engine.
///
///Implementation of `Engine`.
///
///Responsible for such things as checking if a move is valid,
///playing sound on valid moves,
///evaluating check and check mate,
///and eventually figuring out best moves when it acts as an adversary.
///
///Allows Board to be interfaced to be able to move pieces.
class EngineImpl implements Engine {
  late Board _board;
  final AssetsAudioPlayer player;

  EngineImpl({required Board board, required this.player}) {
    this._board = board;
  }

  ///Initializes a chess engine, creates the chess board and an audio player object
  ///for playing sound on moves.
  factory EngineImpl.initialize() {
    return EngineImpl(
      board: Board.createBoard(),
      player: AssetsAudioPlayer.newPlayer(),
    );
  }

  @override
  void movePiece(List<int> currentPosition, List<int> targetPosition) {
    if (_board.movePiece(currentPosition, targetPosition)) {
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
  List<List<Square>> get squares => _board.squares;
}
