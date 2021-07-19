import 'package:chess/presentation/shared/shared.dart';
import 'package:flutter/material.dart';
import 'cubit/board_cubit.dart';
import 'cubit/board_state.dart';

class BoardView extends StatefulWidget {
  const BoardView({Key? key}) : super(key: key);

  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<BoardCubit>().startEngine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardCubit = context.watch<BoardCubit>();
    return Scaffold(
      body: Center(
        child: BlocBuilder<BoardCubit, BoardState>(builder: (_, state) {
          if (state is LoadedBoardState) {
            return ChessBoard(
              squares: state.squares,
              onSquareTapped: boardCubit.onSquareTapped,
            );
          } else if (state is BoardUpdatedState) {
            return ChessBoard(
              squares: state.squares,
              onSquareTapped: boardCubit.onSquareTapped,
              currentPosition: state.currentPosition,
            );
          }
          return Text("");
        }),
      ),
    );
  }
}
