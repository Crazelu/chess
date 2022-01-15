import 'package:chess/utils/constants.dart';

///Individual chess piece on a square.
///
///e.g pawn
class Piece {
  ///Image file for this piece.
  final String image;

  ///Indicates whether piece is a white piece or not.
  final bool isWhite;

  ///Indicates whether this piece is checked.
  ///
  ///Ideally used for the kings.
  final bool isChecked;

  const Piece({
    required this.image,
    this.isWhite = true,
    this.isChecked = false,
  });

  Piece copyWith({bool? isChecked}) {
    return Piece(
      image: this.image,
      isWhite: this.isWhite,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  ///Constructs a Piece object whose image is specified by `initialPosition`
  ///and color by `isWhite`.
  factory Piece.getPiece({
    required String initialPosition,
    required bool isWhite,
  }) {
    switch (initialPosition) {
      case "a8":
      case "a1":
      case "h8":
      case "h1":
        return Piece(image: isWhite ? ROOK : BLACK_ROOK, isWhite: isWhite);
      case "b8":
      case "b1":
      case "g8":
      case "g1":
        return Piece(image: isWhite ? KNIGHT : BLACK_KNIGHT, isWhite: isWhite);
      case "c8":
      case "c1":
      case "f8":
      case "f1":
        return Piece(image: isWhite ? BISHOP : BLACK_BISHOP, isWhite: isWhite);
      case "d8":
      case "d1":
        return Piece(image: isWhite ? QUEEN : BLACK_QUEEN, isWhite: isWhite);
      case "e8":
      case "e1":
        return Piece(image: isWhite ? KING : BLACK_KING, isWhite: isWhite);
      default:
        return Piece(image: isWhite ? PAWN : BLACK_PAWN, isWhite: isWhite);
    }
  }
}
