import 'package:chess/engine/models/board.dart';
import 'package:chess/engine/models/square.dart';

abstract class Engine {
  final Board chessBoard;

  Engine(this.chessBoard);

  List<List<Square>> get squares => chessBoard.squares;

  ///Moves a piece from one square to another
  void movePiece(List<int> currentPosition, List<int> targetPosition);

  void playSound();
}
