import 'package:chess/engine/models/array_position.dart';
import 'package:chess/engine/models/square.dart';

///Chess engine.
///
///Responsible for such things as checking if a move is valid,
///playing sound on valid moves,
///evaluating check and check mate,
///and eventually figuring out best moves when it acts as an adversary.
///
///Allows Board to be interfaced to be able to move pieces.
abstract class Engine {
  ///All of the squares on the chess board.
  List<List<Square>> get squares;

  ///Moves a piece from one square to another.
  void movePiece(List<int> currentPosition, List<int> targetPosition);

  ///Plays sound when a piece is moved.
  void playSound();

  List<ArrayPosition> evaluateValidMoves(List<int> currentPosition);
}
