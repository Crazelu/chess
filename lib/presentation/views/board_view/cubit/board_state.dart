import 'package:chess/engine/models/board.dart';
import 'package:equatable/equatable.dart';

abstract class BoardState {
  const BoardState();
}

class InitialBoardState extends Equatable implements BoardState {
  const InitialBoardState();

  @override
  List<Object?> get props => [1];
}

class LoadingBoardState extends Equatable implements BoardState {
  const LoadingBoardState();
  @override
  List<Object?> get props => [2];
}

class LoadedBoardState extends Equatable implements BoardState {
  final Board board;
  const LoadedBoardState(this.board);

  @override
  List<Object?> get props => [board];
}

class BoardUpdatedState extends Equatable implements BoardState {
  final Board board;
  final List<int>? currentPosition;
  final List<int>? targetPosition;

  const BoardUpdatedState({
    required this.board,
    this.currentPosition,
    this.targetPosition,
  });

  @override
  List<Object?> get props => [board, targetPosition, currentPosition];
}
