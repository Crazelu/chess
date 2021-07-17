import 'package:chess/engine/models/piece.dart';
import 'package:chess/engine/models/square.dart';

///Represents the chess board with 64 squares.
class Board {
  final List<List<Square>> squares;

  Board(this.squares);

  factory Board.createBoard() {
    return Board(generateSquares());
  }

  ///Generates a nested array of ranks which contain squares with specific positions.
  static List<List<Square>> generateSquares() {
    List rankLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    List<List<Square>> board = [];
    bool light = false;

    for (int i = 8; i > 0; i--) {
      light = !light;
      List<Square> outRank = [];
      for (var rankLetter in rankLetters) {
        final position = rankLetter + '$i';
        outRank.add(
          Square(
            light: light,
            position: position,
            piece: i < 3 || i > 6
                ? Piece.getPiece(
                    initialPosition: position,
                    isLightSquare: i < 3,
                  )
                : null,
          ),
        );
        light = !light;
      }
      board.add(outRank);
    }
    return board;
  }
}
