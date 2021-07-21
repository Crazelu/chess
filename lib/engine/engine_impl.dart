import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chess/engine/engine.dart';
import 'package:chess/engine/models/array_position.dart';
import 'package:chess/engine/models/piece.dart';
import 'package:chess/engine/models/piece_type_enum.dart';
import 'package:chess/engine/models/square.dart';
import 'package:chess/engine/models/board.dart';
import 'package:chess/utils/utils.dart';

///Chess engine.
///
///Implementation of `Engine`.
///
///Responsible for such things as checking if a move is valid,
///playing sound on valid moves,
///evaluating check and check mate,
///and eventually figuring out best moves when it acts as an adversary.
///
///Allows Board to be interfaced to be able to move pieces.
class EngineImpl implements Engine {
  late Board _board;
  final AssetsAudioPlayer player;
  bool _canEnPassant = false;
  ArrayPosition? _currentValidEnPassantSquare;
  PieceType _lastPlayedPieceType = PieceType.black;

  EngineImpl({required Board board, required this.player}) {
    this._board = board;
  }

  ///Initializes a chess engine, creates the chess board and an audio player object
  ///for playing sound on moves.
  factory EngineImpl.initialize() {
    return EngineImpl(
      board: Board.createBoard(),
      player: AssetsAudioPlayer.newPlayer(),
    );
  }

  void _setLastPlayedPieceType(Piece piece) {
    _lastPlayedPieceType = _getPieceType(piece);
  }

  PieceType _getPieceType(Piece piece) {
    return piece.image.contains("black") ? PieceType.black : PieceType.white;
  }

  Piece? _getPiece(List<int> currentPosition) {
    print(currentPosition);
    try {
      return squares[currentPosition[0]][currentPosition[1]].piece;
    } catch (e) {}
  }

  @override
  void movePiece(List<int> currentPosition, List<int> targetPosition) {
    Piece? currentPiece = _getPiece(currentPosition);

    //if there's no piece on the current square, this is not
    //a valid move
    if (currentPiece == null) return;

    final validSquares = evaluateValidMoves(currentPosition);
    final targetPos =
        ArrayPosition(rank: targetPosition[0], file: targetPosition[1]);
    print("Current: $currentPosition");
    print("Target: $targetPosition");
    print("Valids: $validSquares");
    print(validSquares.contains(targetPos));
    print("En passant: $_currentValidEnPassantSquare");

    if (validSquares.contains(targetPos) ||
        targetPos == _currentValidEnPassantSquare) {
      PieceType currentPieceType = _getPieceType(currentPiece);

      //same piece type cannot make two consecutive moves
      if (currentPieceType == _lastPlayedPieceType) return;

      if (_canEnPassant && targetPos == _currentValidEnPassantSquare) {
        //handles en passant moves

        final isWhitePiece = currentPiece.isWhite;

        if (_board.movePiece(
          currentPosition,
          targetPosition,
          enPassantSquarePosition: [
            //if piece is a white piece, add 1 to the current valid enpassant square rank
            //to calculate accurate offset, otherwise, subtract 1
            isWhitePiece
                ? _currentValidEnPassantSquare!.rank + 1
                : _currentValidEnPassantSquare!.rank - 1,
            _currentValidEnPassantSquare!.file,
          ],
        )) {
          playSound();

          _setLastPlayedPieceType(currentPiece);

          //only pawn moves can trigger en passant
          if (currentPiece.image == PAWN || currentPiece.image == BLACK_PAWN) {
            _getEnPassantMove(
              currentPosition,
              targetPos,
              currentPiece.isWhite,
            );
          } else {
            _canEnPassant = false;
          }
        }
        return;
      }

      //normal piece movement
      if (_board.movePiece(currentPosition, targetPosition)) {
        playSound();

        _setLastPlayedPieceType(currentPiece);

        //only pawn moves can trigger en passant
        if (currentPiece.image == PAWN || currentPiece.image == BLACK_PAWN) {
          _getEnPassantMove(
            currentPosition,
            targetPos,
            currentPiece.isWhite,
          );
        } else {
          _canEnPassant = false;
        }
      }
    }
    // if (_board.movePiece(currentPosition, targetPosition)) {
    //   playSound();
    // }
  }

  @override
  void playSound() {
    player.open(
      Audio("assets/click.wav"),
    );
  }

  @override
  List<List<Square>> get squares => _board.squares;

  @override
  List<ArrayPosition> evaluateValidMoves(List<int> currentPosition) {
    Piece? currentPiece = squares[currentPosition[0]][currentPosition[1]].piece;

    //if there's no piece on the current square, move is 'invalid'
    //hence there are no valid moves from that position
    if (currentPiece == null) return [];

    switch (currentPiece.image) {
      case PAWN:
      case BLACK_PAWN:
        return _getValidPawnMoves(currentPosition, currentPiece.isWhite);
      case BISHOP:
      case BLACK_BISHOP:
        return _getValidBishopMoves(currentPosition);
      case KNIGHT:
      case BLACK_KNIGHT:
        return _getValidKnightMoves(currentPosition);

      default:
        return [];
    }
  }

  List<ArrayPosition> _getValidKnightMoves(
    List<int> currentPosition,
  ) {
    List<ArrayPosition> validSquares = [];

    try {
      int rank = currentPosition[0];
      int file = currentPosition[1];
      final piece = _getPiece(currentPosition)!;
      final pieceType = _getPieceType(piece);

      if (pieceType == PieceType.white) {
        //calculate first offset (top left corner)
        final offset1 = [rank - 1, file - 2];
        final offset1Piece = _getPiece(offset1);

        if (offset1Piece == null || _getPieceType(offset1Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 1, file: file - 2),
          );
        }
        //calculate second offset (topmost left corner)
        final offset2 = [rank - 2, file - 1];
        final offset2Piece = _getPiece(offset2);

        if (offset2Piece == null || _getPieceType(offset2Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 2, file: file - 1),
          );
        }
        //calculate third offset (topmost right corner)
        final offset3 = [rank - 2, file + 1];
        final offset3Piece = _getPiece(offset3);

        if (offset3Piece == null || _getPieceType(offset3Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 2, file: file + 1),
          );
        }

        //reversed offsets

        //calculate fourth offset (bottom left corner)
        final offset4 = [rank + 1, file + 2];
        final offset4Piece = _getPiece(offset4);

        if (offset4Piece == null || _getPieceType(offset4Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 1, file: file + 2),
          );
        }
        //calculate fifth offset (bottom most left corner)
        final offset5 = [rank + 2, file + 1];
        final offset5Piece = _getPiece(offset5);

        if (offset5Piece == null || _getPieceType(offset5Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 2, file: file + 1),
          );
        }
        //calculate sixth offset (bottom most right corner)
        final offset6 = [rank + 2, file - 1];
        final offset6Piece = _getPiece(offset6);

        if (offset6Piece == null || _getPieceType(offset6Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 2, file: file - 1),
          );
        }
        //diagonal offset
        final offset7 = [rank - 1, file + 2];
        final offset7Piece = _getPiece(offset7);

        if (offset7Piece == null || _getPieceType(offset7Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 1, file: file + 2),
          );
        }
        //diagonal offset
        final offset8 = [rank + 1, file - 2];
        final offset8Piece = _getPiece(offset8);

        if (offset8Piece == null || _getPieceType(offset8Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 1, file: file - 2),
          );
        }
      } else {
        //calculate first offset (top right corner)
        final offset1 = [rank + 1, file - 2];
        final offset1Piece = _getPiece(offset1);

        if (offset1Piece == null || _getPieceType(offset1Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 1, file: file - 2),
          );
        }

        //calculate second offset (topmost right corner)
        final offset2 = [rank + 2, file - 1];
        final offset2Piece = _getPiece(offset2);

        if (offset2Piece == null || _getPieceType(offset2Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 2, file: file - 1),
          );
        }
        //calculate third offset (topmost left corner)
        final offset3 = [rank + 2, file + 1];
        final offset3Piece = _getPiece(offset3);

        if (offset3Piece == null || _getPieceType(offset3Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 2, file: file + 1),
          );
        }

        //reverse offsets

        //reverses offset1
        final offset4 = [rank - 1, file + 2];
        final offset4Piece = _getPiece(offset4);

        if (offset4Piece == null || _getPieceType(offset4Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 1, file: file + 2),
          );
        }

        //reverses offset2
        final offset5 = [rank - 2, file + 1];
        final offset5Piece = _getPiece(offset5);

        if (offset5Piece == null || _getPieceType(offset5Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 2, file: file + 1),
          );
        }
        //reverses offset3
        final offset6 = [rank - 2, file - 1];
        final offset6Piece = _getPiece(offset6);

        if (offset6Piece == null || _getPieceType(offset6Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 2, file: file - 1),
          );
        }
        //diagonal offset
        final offset7 = [rank - 1, file - 2];
        final offset7Piece = _getPiece(offset7);

        if (offset7Piece == null || _getPieceType(offset7Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank - 1, file: file - 2),
          );
        }
        //diagonal offset
        final offset8 = [rank + 1, file + 2];
        final offset8Piece = _getPiece(offset8);

        if (offset8Piece == null || _getPieceType(offset8Piece) != pieceType) {
          validSquares.add(
            ArrayPosition(rank: rank + 1, file: file + 2),
          );
        }
      }
    } catch (e) {
      print(e);
    }
    return validSquares;
  }

  List<ArrayPosition> _getValidBishopMoves(
    List<int> currentPosition,
  ) {
    List<ArrayPosition> validSquares = [];

    try {
      int rank = currentPosition[0];
    } catch (e) {
      print(e);
    }
    return validSquares;
  }

  void _getEnPassantMove(
    List<int> currentPosition,
    ArrayPosition targetPosition,
    bool isWhite,
  ) {
//for an en passant move to occur, the last pawn move must be two squares in the
//vertical direction (along a file) to a target position
//and new pawn move has to begin with a current position whose rank is same as
//the last pawn move's rank and new pawn has to be of opposite color

    print(currentPosition[0] - targetPosition.rank);

    if ((currentPosition[0] - targetPosition.rank).abs() == 2) {
      _canEnPassant = true;
      _currentValidEnPassantSquare = ArrayPosition(
          rank: isWhite ? targetPosition.rank + 1 : targetPosition.rank - 1,
          file: targetPosition.file);
    } else {
      _canEnPassant = false;
      _currentValidEnPassantSquare = null;
    }
  }

  List<ArrayPosition> _getCapturableAdjacentPawnMoves(
    int rank,
    int file,
    bool isWhite,
  ) {
    List<ArrayPosition> validSquares = [];
    try {
      switch (isWhite) {
        //if it's a white pawn, calculate the adjacent offsets by first finding the next rank
        //which is essentially the current rank - 1
        //then get adjacent files by adding and subtracting 1 from the current file
        case true:
          final nextRank = rank - 1;
          final rightAdjacentPiece = _getPiece([nextRank, file + 1]);
          if (rightAdjacentPiece != null &&
              rightAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition(rank: nextRank, file: file + 1),
            );
          }
          final leftAdjacentPiece = _getPiece([nextRank, file - 1]);
          if (leftAdjacentPiece != null &&
              leftAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition(rank: nextRank, file: file - 1),
            );
          }
          break;
        default:
          //if it's a black pawn, calculate the adjacent offsets by first finding the next rank
          //which is essentially the current rank + 1
          //then get adjacent files by adding and subtracting 1 from the current file
          final nextRank = rank + 1;
          final rightAdjacentPiece = _getPiece([nextRank, file - 1]);
          if (rightAdjacentPiece != null &&
              rightAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition(rank: nextRank, file: file - 1),
            );
          }
          final leftAdjacentPiece = _getPiece([nextRank, file + 1]);
          if (leftAdjacentPiece != null &&
              leftAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition(rank: nextRank, file: file + 1),
            );
          }
      }
    } catch (e) {
      print(e);
    }

    return validSquares;
  }

  List<ArrayPosition> _getValidPawnMoves(
    List<int> currentPosition,
    bool isWhite,
  ) {
    //if pawn is still on the 7th or 2nd rank, they can move one or
    //two steps vertically up the board

    int rank = currentPosition[0];
    int file = currentPosition[1];
    print(currentPosition);
    List<ArrayPosition> validSquares = [];

    try {
      final capturableSquares =
          _getCapturableAdjacentPawnMoves(rank, file, isWhite);

      if (capturableSquares.length != 0) {
        validSquares.addAll(capturableSquares);
      }

      switch (rank) {
        case 1:
          //7th rank (black)
          //since pawns on this rank can go as far as two steps in a
          //vertical direction, check if there are pieces on any of the
          //two downward squares and don't include them as valid squares if they have
          //enemy pieces

          final piece = _getPiece([rank + 1, file]);
          //if a white piece makes it to this rank, it shouldn't be able to move
          //upward like a black piece

          if (piece == null) {
            if (isWhite) return validSquares;
            validSquares.add(
              ArrayPosition(rank: rank + 1, file: file),
            );
          } else {
            return validSquares;
          }
          if (_getPiece([rank + 2, file]) == null) {
            validSquares.add(
              ArrayPosition(rank: rank + 2, file: file),
            );
          }
          break;
        case 6:
          //2nd rank (white)
          //since pawns on this rank can go as far as two steps in a
          //vertical direction, check if there are pieces on any of the
          //two upward squares and don't include them as valid squares if they have
          //enemy pieces

          final piece = _getPiece([rank - 1, file]);
          //if a black piece makes it to this rank, it shouldn't be able to move
          //upward like a white piece

          if (piece == null) {
            if (!isWhite) return validSquares;
            validSquares.add(
              ArrayPosition(rank: rank - 1, file: file),
            );
          } else {
            return validSquares;
          }
          if (_getPiece([rank - 2, file]) == null) {
            validSquares.add(
              ArrayPosition(rank: rank - 2, file: file),
            );
          }
          break;
        default:
          //if pawn is not on 7th ond 2nd rank, it can only move one square vertically

          if (isWhite) {
            //white pawns can only move one square up the board
            if (_getPiece([rank - 1, file]) == null) {
              validSquares.add(
                ArrayPosition(rank: rank - 1, file: file),
              );
            } else {
              return validSquares;
            }
          } else {
            //black pawns can only move one square down the board
            if (_getPiece([rank + 1, file]) == null) {
              validSquares.add(
                ArrayPosition(rank: rank + 1, file: file),
              );
            } else {
              return validSquares;
            }
          }
      }
    } catch (e) {
      print(e);
    }

    return validSquares;
  }
}
