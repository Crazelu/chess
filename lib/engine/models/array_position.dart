import 'package:equatable/equatable.dart';

class ArrayPosition extends Equatable {
  final int rank;
  final int file;

  ArrayPosition({required this.rank, required this.file});

  @override
  List<Object?> get props => [rank, file];
}
