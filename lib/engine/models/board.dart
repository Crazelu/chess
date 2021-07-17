import 'package:chess/engine/models/square.dart';

///Represents the chess board with 64 squares.
class Board {
  final List<List<Square>> squares;

  Board(this.squares);

  factory Board.createBoard() {
    return Board(generateSquares());
  }

  static List<List<Square>> generateSquares() {
    List rankLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    List<List<Square>> board = [];
    bool light = false;

    for (int i = 8; i > 0; i--) {
      light = !light;
      List<Square> outRank = [];
      for (var rankLetter in rankLetters) {
        outRank.add(
          Square(
            light: light,
            position: rankLetter + '$i',
          ),
        );
        light = !light;
      }
      board.add(outRank);
    }
    return board;
  }
}

void main() {
  Board.createBoard();
}
