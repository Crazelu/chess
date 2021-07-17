import 'package:chess/engine/models/board.dart';
import 'package:chess/presentation/shared/square.dart';
import 'package:flutter/material.dart';

class BoardView extends StatefulWidget {
  const BoardView({Key? key}) : super(key: key);

  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late Board chessBoard;
  List<int>? currentPosition;
  List<int>? targetPosition;
  @override
  void initState() {
    super.initState();
    chessBoard = Board.createBoard();
  }

  void onSquareTapped(List<int> squarePosition) {
    if (currentPosition == squarePosition) return;
    if (currentPosition == null) {
      setState(() {
        currentPosition = squarePosition;
      });
    } else {
      setState(() {
        targetPosition = squarePosition;
      });
      movePiece();
    }
  }

  void movePiece() {
    if (currentPosition != null && targetPosition != null) {
      chessBoard.movePiece(currentPosition!, targetPosition!);
      setState(() {
        currentPosition = null;
        targetPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chessBoard.squares
              .map(
                (rank) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rank
                      .map(
                        (square) => SquareWidget(
                          square: square,
                          onSquareTapped: onSquareTapped,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
