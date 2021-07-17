import 'package:chess/engine/models/board.dart';

class ChessBoardRepo {
  late Board _chessBoard;
  List<int>? _currentPosition;
  List<int>? _targetPosition;

  Board createBoard() {
    _chessBoard = Board.createBoard();
    return _chessBoard;
  }

  Board get chessBoard => _chessBoard;

  List<List<int>?> onSquareTapped(
      List<int> squarePosition, Function playSound) {
    if (_currentPosition == null) {
      _currentPosition = squarePosition;
    } else {
      _targetPosition = squarePosition;

      movePiece(playSound);
    }

    return [_currentPosition, _targetPosition];
  }

  void movePiece(Function playSound) {
    if (_currentPosition != null && _targetPosition != null) {
      final moved = _chessBoard.movePiece(_currentPosition!, _targetPosition!);

      if (moved) {
        playSound();
      }

      _currentPosition = null;
      _targetPosition = null;
    }
  }
}
