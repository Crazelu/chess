import 'package:equatable/equatable.dart';

///Represents the coordinates of a square on the chess board.
///
///This object can be compared with similar objects based on values and not referece
///which is the default behaviour with Dart.
class ArrayPosition extends Equatable {
  final int rank;
  final int file;

  ArrayPosition({required this.rank, required this.file});

  factory ArrayPosition.fromList(List<int> pos) {
    return ArrayPosition(rank: pos[0], file: pos[1]);
  }

  @override
  List<Object?> get props => [rank, file];
}
