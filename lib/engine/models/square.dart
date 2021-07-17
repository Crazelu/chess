import 'package:chess/engine/models/piece.dart';

///Represents an individual square on a chess board.
class Square {
  ///Indicates whether the sqaure is a light square or not
  final bool isLightSquare;

  ///Position of square on board following standard notations.
  ///
  ///e.g `a8`
  final String position;

  ///Position of this square on the board given as `[x,y]` coordinate of the square
  ///where x is in the rank axis and y is in the file axis.
  final List<int> arrayPos;

  ///Represents what chess piece this square holds at a point in time.
  Piece? piece;

  ///Represents an individual square on a chess board at
  ///position specified by `position`.
  ///
  ///The square is a light square if `light = true`. Otherwise,
  ///the square is a dark square.
  Square({
    required this.isLightSquare,
    required this.position,
    required this.arrayPos,
    this.piece,
  });
}
