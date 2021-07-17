import 'package:chess/data/repositories/chess_board_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_state.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class BoardCubit extends Cubit<BoardState> {
  final ChessBoardRepo repository;
  BoardCubit(this.repository) : super(InitialBoardState()) {
    player = AssetsAudioPlayer.newPlayer();
  }

  late AssetsAudioPlayer player;

  void playSound() {
    player.open(
      Audio("assets/click.wav"),
    );
  }

  void createBoard() {
    final chessBoard = repository.createBoard();
    emit(LoadedBoardState(chessBoard));
  }

  void onSquareTapped(List<int> squarePosition) {
    final positions =
        repository.onSquareTapped(squarePosition, () => playSound());
    emit(
      BoardUpdatedState(
        board: repository.chessBoard,
        currentPosition: positions[0],
        targetPosition: positions[1],
      ),
    );
  }
}
