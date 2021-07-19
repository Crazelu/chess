import 'package:chess/engine/engine.dart';
import 'package:chess/engine/engine_impl.dart';
import 'package:chess/engine/models/square.dart';

class ChessBoardRepo {
  late Engine _engine;
  List<int>? _currentPosition;
  List<int>? _targetPosition;

  List<List<Square>> get squares => _engine.squares;

  void startEngine() {
    _engine = EngineImpl.initialize();
  }

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
      _engine.movePiece(_currentPosition!, _targetPosition!);

      _currentPosition = null;
      _targetPosition = null;
    }
  }
}
