import 'package:chess/engine/models/piece.dart';
import 'package:chess/utils/constants.dart';

///Represents an individual square on a chess board.
class Square {
  ///Indicates whether the sqaure is a light square or not
  final bool light;

  ///Position of square on board following standard notations.
  ///
  ///e.g `a8`
  final String position;

  ///Represents what chess piece this square holds at a point in time.
  final Piece piece;

  ///Represents an individual square on a chess board at
  ///position specified by `position`.
  ///
  ///The square is a light square if `light = true`. Otherwise,
  ///the square is a dark square.
  Square({
    required this.light,
    required this.position,
    this.piece = const Piece(image: PAWN),
  });
}
