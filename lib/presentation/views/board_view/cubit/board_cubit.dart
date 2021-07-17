import 'package:chess/presentation/views/board_view/board_view_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_state.dart';

class BoardCubit extends Cubit<BoardState> {
  final BoardViewRepository repository;
  BoardCubit(this.repository) : super(InitialBoardState());

  void createBoard() {
    emit(LoadingBoardState());
    final chessBoard = repository.createBoard();
    emit(LoadedBoardState(chessBoard));
  }

  void onSquareTapped(List<int> squarePosition) {
    final positions = repository.onSquareTapped(squarePosition);
    emit(
      BoardUpdatedState(
        board: repository.chessBoard,
        currentPosition: positions[0],
        targetPosition: positions[1],
      ),
    );
  }
}
