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
  @override
  void initState() {
    super.initState();
    chessBoard = Board.createBoard();
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
                        (square) => SquareWidget(square: square),
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
