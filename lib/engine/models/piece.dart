import 'package:chess/utils/constants.dart';

///Individual chess piece on a square.
///
///e.g pawn
class Piece {
  ///Image file for this piece.
  final String image;

  ///Indicates whether piece is on a light square or not.
  final bool light;

  const Piece({
    required this.image,
    this.light = true,
  });

  ///Constructs a Piece object whose image is specified by `initialPosition`
  ///and color by `isLightSquare`.
  factory Piece.getPiece({
    required String initialPosition,
    required bool isLightSquare,
  }) {
    switch (initialPosition) {
      case "a8":
      case "a1":
      case "h8":
      case "h1":
        return Piece(
            image: isLightSquare ? ROOK : BLACK_ROOK, light: isLightSquare);
      case "b8":
      case "b1":
      case "g8":
      case "g1":
        return Piece(
            image: isLightSquare ? KNIGHT : BLACK_KNIGHT, light: isLightSquare);
      case "c8":
      case "c1":
      case "f8":
      case "f1":
        return Piece(
            image: isLightSquare ? BISHOP : BLACK_BISHOP, light: isLightSquare);
      case "d8":
      case "d1":
        return Piece(
            image: isLightSquare ? QUEEN : BLACK_QUEEN, light: isLightSquare);
      case "e8":
      case "e1":
        return Piece(
            image: isLightSquare ? KING : BLACK_KING, light: isLightSquare);
      default:
        return Piece(
            image: isLightSquare ? PAWN : BLACK_PAWN, light: isLightSquare);
    }
  }
}
