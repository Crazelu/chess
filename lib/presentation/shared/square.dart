import 'package:chess/engine/models/square.dart';
import 'package:flutter/material.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  const SquareWidget({
    Key? key,
    required this.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      height: width / 8,
      width: width / 8,
      color: square.light ? Colors.grey[200] : Colors.blueGrey[600],
      child: square.piece == null
          ? Text("${square.arrayPos[0]}${square.arrayPos[1]}")
          : Image.asset(
              square.piece!.image,
            ),
    );
  }
}
