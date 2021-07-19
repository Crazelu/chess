import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chess/engine/engine.dart';
import 'package:chess/engine/models/array_position.dart';
import 'package:chess/engine/models/piece.dart';
import 'package:chess/engine/models/square.dart';
import 'package:chess/engine/models/board.dart';
import 'package:chess/utils/utils.dart';

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
    final validSquares = evaluateValidMoves(currentPosition);
    final targetPos =
        ArrayPosition(rank: targetPosition[0], file: targetPosition[1]);
    print("Target: $targetPosition");
    print("Valids: $validSquares");
    print(validSquares.contains(targetPos));

    if (validSquares.contains(targetPos)) {
      if (_board.movePiece(currentPosition, targetPosition)) {
        playSound();
      }
    }
    // if (_board.movePiece(currentPosition, targetPosition)) {
    //   playSound();
    // }
  }

  @override
  void playSound() {
    player.open(
      Audio("assets/click.wav"),
    );
  }

  @override
  List<List<Square>> get squares => _board.squares;

  @override
  List<ArrayPosition> evaluateValidMoves(List<int> currentPosition) {
    Piece? currentPiece = squares[currentPosition[0]][currentPosition[1]].piece;

    //if there's no piece on the current square, move is 'invalid'
    //hence there are no valid moves from that position
    if (currentPiece == null) return [];

    switch (currentPiece.image) {
      case PAWN:
      case BLACK_PAWN:
        return _getValidPawnMoves(currentPosition, currentPiece.isWhite);

      default:
        return [];
    }
  }

  List<ArrayPosition> _getValidPawnMoves(
    List<int> currentPosition,
    bool isWhite,
  ) {
    //if pawn is still on the 7th or 2nd rank, they can move one or
    //two steps vertically up the board

    int rank = currentPosition[0];
    int file = currentPosition[1];
    print(currentPosition);
    List<ArrayPosition> validSquares = [];

    switch (rank) {
      case 1:
        //7th rank (black)
        //since pawns on this rank can go as far as two steps in a
        //vertical direction, check if there are pieces on any of the
        //two downward squares and don't include them as valid squares if they have
        //enemy pieces

        if (squares[rank + 1][file].piece == null) {
          validSquares.add(
            ArrayPosition(rank: rank + 1, file: file),
          );
        } else {
          return validSquares;
        }
        if (squares[rank + 2][file].piece == null) {
          validSquares.add(
            ArrayPosition(rank: rank + 2, file: file),
          );
        }
        break;
      case 6:
        //2nd rank (white)
        //since pawns on this rank can go as far as two steps in a
        //vertical direction, check if there are pieces on any of the
        //two upward squares and don't include them as valid squares if they have
        //enemy pieces
        if (squares[rank - 1][file].piece == null) {
          validSquares.add(
            ArrayPosition(rank: rank - 1, file: file),
          );
        } else {
          return validSquares;
        }
        if (squares[rank - 2][file].piece == null) {
          validSquares.add(
            ArrayPosition(rank: rank - 2, file: file),
          );
        }
        break;
      default:
        //if pawn is not on 7th ond 2nd rank, it can only move one square vertically

        if (isWhite) {
          //white pawns can only move one square up the board
          if (squares[rank - 1][file].piece == null) {
            validSquares.add(
              ArrayPosition(rank: rank - 1, file: file),
            );
          } else {
            return validSquares;
          }
        } else {
          //black pawns can only move one square down the board
          if (squares[rank + 1][file].piece == null) {
            validSquares.add(
              ArrayPosition(rank: rank + 1, file: file),
            );
          } else {
            return validSquares;
          }
        }
    }

    return validSquares;
  }
}
