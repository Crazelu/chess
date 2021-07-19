import 'package:chess/data/repositories/chess_board_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_state.dart';

class BoardCubit extends Cubit<BoardState> {
  final ChessBoardRepo repository;
  BoardCubit(this.repository) : super(InitialBoardState()) {}

  void startEngine() {
    repository.startEngine();
    emit(LoadedBoardState(repository.squares));
  }

  void onSquareTapped(List<int> squarePosition) {
    final positions = repository.onSquareTapped(squarePosition);
    emit(
      BoardUpdatedState(
        squares: repository.squares,
        currentPosition: positions[0],
        targetPosition: positions[1],
      ),
    );
  }
}
