import 'package:chess/engine/models/board.dart';

class BoardViewRepository {
  late Board _chessBoard;
  List<int>? _currentPosition;
  List<int>? _targetPosition;

  Board createBoard() {
    _chessBoard = Board.createBoard();
    return _chessBoard;
  }

  Board get chessBoard => _chessBoard;

  List<List<int>?> onSquareTapped(List<int> squarePosition) {
    if (_currentPosition == null) {
      _currentPosition = squarePosition;
    } else {
      _targetPosition = squarePosition;

      movePiece();
    }

    return [_currentPosition, _targetPosition];
  }

  void movePiece() {
    if (_currentPosition != null && _targetPosition != null) {
      _chessBoard.movePiece(_currentPosition!, _targetPosition!);

      _currentPosition = null;
      _targetPosition = null;
    }
  }
}
