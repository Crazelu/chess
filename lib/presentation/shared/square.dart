import 'package:chess/engine/models/square.dart';
import 'package:flutter/material.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  final Function(List<int>) onSquareTapped;
  const SquareWidget({
    Key? key,
    required this.square,
    required this.onSquareTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        onSquareTapped(square.arrayPos);
      },
      child: Container(
        alignment: Alignment.center,
        height: width / 8,
        width: width / 8,
        color: square.light ? Colors.grey[200] : Colors.blueGrey[600],
        child: square.piece == null
            ? null
            : Image.asset(
                square.piece!.image,
              ),
      ),
    );
  }
}
