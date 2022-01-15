import 'package:chess/engine/models/square.dart';
import 'package:equatable/equatable.dart';

abstract class BoardState {
  const BoardState();
}

class InitialBoardState extends Equatable implements BoardState {
  const InitialBoardState();

  @override
  List<Object?> get props => [1];
}

class LoadedBoardState extends Equatable implements BoardState {
  final List<List<Square>> squares;
  const LoadedBoardState(this.squares);

  @override
  List<Object?> get props => [squares];
}

class BoardUpdatedState extends Equatable implements BoardState {
  final List<List<Square>> squares;
  final List<int>? currentPosition;
  final List<int>? targetPosition;
  final bool isChecked;

  const BoardUpdatedState({
    required this.squares,
    this.isChecked = false,
    this.currentPosition,
    this.targetPosition,
  });

  @override
  List<Object?> get props => [
        squares,
        isChecked,
        targetPosition,
        currentPosition,
      ];
}
