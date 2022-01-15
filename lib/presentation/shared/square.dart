import 'package:chess/engine/models/square.dart';
import 'package:chess/utils/utils.dart';
import 'package:flutter/material.dart';

class SquareWidget extends StatelessWidget {
  final List<int>? currentPosition;
  final Square square;
  final Function(List<int>) onSquareTapped;
  final bool isChecked;

  const SquareWidget({
    Key? key,
    required this.square,
    required this.onSquareTapped,
    this.isChecked = false,
    this.currentPosition,
  }) : super(key: key);

  BorderSide get borderSide => BorderSide(
        color: Colors.blueAccent,
        width: 2,
      );
  BorderSide get checkedBorderSide => BorderSide(
        color: Colors.redAccent,
        width: 2,
      );

  //Add a border to indicate that the square is selected at the time
  Border? get border => isChecked
      ? Border(
          top: checkedBorderSide,
          bottom: checkedBorderSide,
          left: checkedBorderSide,
          right: checkedBorderSide,
        )
      : currentPosition == square.arrayPos
          ? Border(
              top: borderSide,
              bottom: borderSide,
              left: borderSide,
              right: borderSide,
            )
          : null;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSquareTapped(square.arrayPos);
      },
      child: Container(
        alignment: Alignment.center,
        height: context.screenWidth(.12),
        width: context.screenWidth(.12),
        decoration: BoxDecoration(
          color: square.isLightSquare ? Colors.grey[200] : Colors.blueGrey[600],
          border: border,
        ),
        child: square.piece == null
            ? null
            : Image.asset(
                square.piece!.image,
              ),
      ),
    );
  }
}
