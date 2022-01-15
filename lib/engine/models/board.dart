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
      int fileNo = 0;
      List<Square> outRank = [];
      for (var rankLetter in rankLetters) {
        final position = rankLetter + '$i';
        outRank.add(
          Square(
            arrayPos: [8 - i, fileNo],
            isLightSquare: light,
            position: position,
            piece: i < 3 || i > 6
                ? Piece.getPiece(
                    initialPosition: position,
                    isWhite: i < 3,
                  )
                : null,
          ),
        );
        light = !light;
        fileNo++;
      }
      board.add(outRank);
    }
    return board;
  }

  ///Moves a piece from one square to another.
  ///
  ///If [enPassantSquarePosition] is not null, it makes an en passant move.
  bool movePiece(
    List<int> currentPosition,
    List<int> targetPosition, {
    List<int>? enPassantSquarePosition,
  }) {
    //if the current and target positions are same, this is not a valid
    //piece movement flow, do nothing
    if (currentPosition == targetPosition) return false;

    Square currentSquare = this.squares[currentPosition[0]][currentPosition[1]];
    Square targetSquare = this.squares[targetPosition[0]][targetPosition[1]];

    targetSquare.piece = currentSquare.piece;
    currentSquare.piece = null;

    if (enPassantSquarePosition != null) {
      //en passant move is triggered
      Square enPassantSquare =
          this.squares[enPassantSquarePosition[0]][enPassantSquarePosition[1]];

      enPassantSquare.piece = null;
    }
    return true;
  }
}
