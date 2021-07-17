import 'package:chess/presentation/views/board_view/chess_board_repository.dart';
import 'package:chess/presentation/views/board_view/cubit/board_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppProviders {
  static final providers = [
    BlocProvider(
      create: (_) => BoardCubit(ChessBoardRepo()),
    )
  ];
}
