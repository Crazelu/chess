import 'package:chess/data/repositories/chess_board_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_state.dart';

class BoardCubit extends Cubit<BoardState> {
  final ChessBoardRepo repository;
  BoardCubit(this.repository) : super(InitialBoardState());

  void createBoard() {
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
