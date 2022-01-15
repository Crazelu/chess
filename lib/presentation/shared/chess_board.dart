import 'package:chess/engine/models/square.dart';
import 'package:chess/presentation/shared/square.dart';
import 'package:flutter/material.dart';

class ChessBoard extends StatelessWidget {
  final List<List<Square>> squares;
  final Function(List<int>) onSquareTapped;
  final List<int>? currentPosition;

  const ChessBoard({
    Key? key,
    required this.squares,
    required this.onSquareTapped,
    this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: squares
          .map(
            (rank) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rank
                  .map(
                    (square) => SquareWidget(
                      square: square,
                      onSquareTapped: onSquareTapped,
                      currentPosition: currentPosition,
                      isChecked: square.piece?.isChecked ?? false,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
