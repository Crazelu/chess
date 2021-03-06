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

  late ArrayPosition _blackKingPosition;
  late ArrayPosition _whiteKingPosition;

  ArrayPosition? _lastBlackMove;
  ArrayPosition? _lastWhiteMove;

  EngineImpl({required Board board, required this.player}) {
    this._board = board;
    this._blackKingPosition = ArrayPosition(rank: 0, file: 4);
    this._whiteKingPosition = ArrayPosition(rank: 7, file: 4);
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
    final targetPos = ArrayPosition.fromList(targetPosition);
    print("Current: $currentPosition");
    print("Target: $targetPosition");
    print("Valids: $validSquares");
    print(validSquares.contains(targetPos));
    print("En passant: $_currentValidEnPassantSquare");

    //same piece type cannot make two consecutive moves
    if (_getPieceType(currentPiece) == _lastPlayedPieceType) return;

    //king cannot be captured
    if (_isAttemptingToCaptureKing(targetPos)) return;

    final isWhitePiece = currentPiece.isWhite;

    if (targetPos == _currentValidEnPassantSquare) {
      if (_canEnPassant &&
          targetPos == _currentValidEnPassantSquare &&
          (currentPiece.image == PAWN || currentPiece.image == BLACK_PAWN)) {
        //handles en passant moves

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

          //set last moves
          //this is useful for evaluating whether the piece
          //on that square still gives a check immediately after another piece
          //has moved
          if (isWhitePiece) {
            _lastWhiteMove = targetPos;
          } else {
            _lastBlackMove = targetPos;
          }

          //evaluate if the previously moved piece still(or now) gives
          //a check immediately after a piece of the opposite color has moved
          if (isWhitePiece && _lastBlackMove != null) {
            evaluateCheck([_lastBlackMove!.rank, _lastBlackMove!.file], false);
          }
          if (!isWhitePiece && _lastWhiteMove != null) {
            evaluateCheck([_lastWhiteMove!.rank, _lastWhiteMove!.file], true);
          }

          //evaluate if the piece which just moved gives a check
          evaluateCheck(targetPosition, isWhitePiece);

          _canEnPassant = false;
          _currentValidEnPassantSquare = null;
        }
        return;
      }
    }

    if (validSquares.contains(targetPos)) {
      //normal piece movement
      if (_board.movePiece(currentPosition, targetPosition)) {
        playSound();
        _setLastPlayedPieceType(currentPiece);

        //set last moves
        //this is useful for evaluating whether the piece
        //on that square still gives a check immediately after another piece
        //has moved
        if (isWhitePiece) {
          _lastWhiteMove = targetPos;
        } else {
          _lastBlackMove = targetPos;
        }

        //keep track of the positions of the kings
        //to always evaluate checks
        if (currentPiece.image == KING) {
          _whiteKingPosition = targetPos;
        }
        if (currentPiece.image == BLACK_KING) {
          _blackKingPosition = targetPos;
        }

        //evaluate if the previously moved piece still(or now) gives
        //a check immediately after a piece of the opposite color has moved
        if (isWhitePiece && _lastBlackMove != null) {
          evaluateCheck([_lastBlackMove!.rank, _lastBlackMove!.file], false);
        }
        if (!isWhitePiece && _lastWhiteMove != null) {
          evaluateCheck([_lastWhiteMove!.rank, _lastWhiteMove!.file], true);
        }

        //evaluate if the piece which just moved gives a check
        evaluateCheck(targetPosition, isWhitePiece);

        //only pawn moves can trigger en passant
        if (currentPiece.image == PAWN || currentPiece.image == BLACK_PAWN) {
          _getEnPassantMove(
            currentPosition,
            targetPos,
            currentPiece.isWhite,
          );
        } else {
          _canEnPassant = false;
          _currentValidEnPassantSquare = null;
        }
      }
    }
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
      case ROOK:
      case BLACK_ROOK:
        return _getValidRookMoves(currentPosition);
      case QUEEN:
      case BLACK_QUEEN:
        return _getValidQueenMoves(currentPosition);
      case KING:
      case BLACK_KING:
        return _getValidKingMoves(currentPosition);

      default:
        return [];
    }
  }

  List<ArrayPosition> _getValidQueenMoves(List<int> currentPosition) {
    List<ArrayPosition> validSquares = [];
    try {
      //I figured a queen is basically a bishop and rook on steroids
      validSquares += _getValidBishopMoves(currentPosition);
      validSquares += _getValidRookMoves(currentPosition);
    } catch (e) {}
    return validSquares;
  }

  List<ArrayPosition> _getValidRookMoves(List<int> currentPosition) {
    List<ArrayPosition> validSquares = [];
    try {
      var currentRank = currentPosition[0];
      var currentFile = currentPosition[1];
      final pieceType = _getPieceType(_getPiece(currentPosition)!);

      while (currentFile < 7) {
        //moves rook to the right side of the board
        final nextPiece = _getPiece([currentRank, currentFile + 1]);
        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank, currentFile + 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank, currentFile + 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentFile++;
      }
      currentFile = currentPosition[1];

      while (currentFile > 0) {
        //moves rook to the left side of the board
        final nextPiece = _getPiece([currentRank, currentFile - 1]);
        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank, currentFile - 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank, currentFile - 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentFile--;
      }
      currentFile = currentPosition[1];

      while (currentRank < 7) {
        //moves rook up a file
        final nextPiece = _getPiece([currentRank + 1, currentFile]);
        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile],
            ),
          );
          break;
        } else {
          break;
        }
        currentRank++;
      }

      currentRank = currentPosition[0];

      while (currentRank > 0) {
        //moves rook down a file
        final nextPiece = _getPiece([currentRank - 1, currentFile]);
        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile],
            ),
          );
          break;
        } else {
          break;
        }

        currentRank--;
      }
    } catch (e) {}
    return validSquares;
  }

  List<ArrayPosition> _getValidKnightMoves(List<int> currentPosition) {
    List<ArrayPosition> validSquares = [];

    try {
      int rank = currentPosition[0];
      int file = currentPosition[1];
      final pieceType = _getPieceType(_getPiece(currentPosition)!);

      if (pieceType == PieceType.white) {
        //calculate first offset (top left corner)
        final offset1 = [rank - 1, file - 2];
        final offset1Piece = _getPiece(offset1);

        if (offset1Piece == null || _getPieceType(offset1Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset1),
          );
        }
        //calculate second offset (topmost left corner)
        final offset2 = [rank - 2, file - 1];
        final offset2Piece = _getPiece(offset2);

        if (offset2Piece == null || _getPieceType(offset2Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset2),
          );
        }
        //calculate third offset (topmost right corner)
        final offset3 = [rank - 2, file + 1];
        final offset3Piece = _getPiece(offset3);

        if (offset3Piece == null || _getPieceType(offset3Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset3),
          );
        }

        //reversed offsets

        //calculate fourth offset (bottom left corner)
        final offset4 = [rank + 1, file + 2];
        final offset4Piece = _getPiece(offset4);

        if (offset4Piece == null || _getPieceType(offset4Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset4),
          );
        }
        //calculate fifth offset (bottom most left corner)
        final offset5 = [rank + 2, file + 1];
        final offset5Piece = _getPiece(offset5);

        if (offset5Piece == null || _getPieceType(offset5Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset5),
          );
        }
        //calculate sixth offset (bottom most right corner)
        final offset6 = [rank + 2, file - 1];
        final offset6Piece = _getPiece(offset6);

        if (offset6Piece == null || _getPieceType(offset6Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset6),
          );
        }
        //diagonal offset
        final offset7 = [rank - 1, file + 2];
        final offset7Piece = _getPiece(offset7);

        if (offset7Piece == null || _getPieceType(offset7Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset7),
          );
        }
        //diagonal offset
        final offset8 = [rank + 1, file - 2];
        final offset8Piece = _getPiece(offset8);

        if (offset8Piece == null || _getPieceType(offset8Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset8),
          );
        }
      } else {
        //calculate first offset (top right corner)
        final offset1 = [rank + 1, file - 2];
        final offset1Piece = _getPiece(offset1);

        if (offset1Piece == null || _getPieceType(offset1Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset1),
          );
        }

        //calculate second offset (topmost right corner)
        final offset2 = [rank + 2, file - 1];
        final offset2Piece = _getPiece(offset2);

        if (offset2Piece == null || _getPieceType(offset2Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset2),
          );
        }
        //calculate third offset (topmost left corner)
        final offset3 = [rank + 2, file + 1];
        final offset3Piece = _getPiece(offset3);

        if (offset3Piece == null || _getPieceType(offset3Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset3),
          );
        }

        //reverse offsets

        //reverses offset1
        final offset4 = [rank - 1, file + 2];
        final offset4Piece = _getPiece(offset4);

        if (offset4Piece == null || _getPieceType(offset4Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset4),
          );
        }

        //reverses offset2
        final offset5 = [rank - 2, file + 1];
        final offset5Piece = _getPiece(offset5);

        if (offset5Piece == null || _getPieceType(offset5Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset5),
          );
        }
        //reverses offset3
        final offset6 = [rank - 2, file - 1];
        final offset6Piece = _getPiece(offset6);

        if (offset6Piece == null || _getPieceType(offset6Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset6),
          );
        }
        //diagonal offset
        final offset7 = [rank - 1, file - 2];
        final offset7Piece = _getPiece(offset7);

        if (offset7Piece == null || _getPieceType(offset7Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset7),
          );
        }
        //diagonal offset
        final offset8 = [rank + 1, file + 2];
        final offset8Piece = _getPiece(offset8);

        if (offset8Piece == null || _getPieceType(offset8Piece) != pieceType) {
          validSquares.add(
            ArrayPosition.fromList(offset8),
          );
        }
      }
    } catch (e) {}
    return validSquares;
  }

  List<ArrayPosition> _getValidBishopMoves(
    List<int> currentPosition,
  ) {
    List<ArrayPosition> validSquares = [];

    try {
      final file = currentPosition[1];
      var currentRank = currentPosition[0];
      var currentFile = currentPosition[1];
      final pieceType = _getPieceType(_getPiece(currentPosition)!);

      //strategies
      //----------------------------------------------------------------------------------
      //bishops can move in four possible diagonals:
      //1: rank decreases as file increases (right upward diagonal for a white bishop)
      //2: rank decreases as file decreases (left upward diagonal for a white bishop)
      //3: rank increases as file increases (right downward diagonal for a white bishop)
      //4: rank increases as file decreases (left downward diagonal for a white bishop)
      //-----------------------------------------------------------------------------------

      //first strategy
      for (int i = 0; i < 7 - file; i++) {
        if (currentRank - 1 < 0) break;

        final nextPiece = _getPiece([currentRank - 1, currentFile + 1]);

        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile + 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile + 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentRank--;
        currentFile++;
      }

      currentRank = currentPosition[0];
      currentFile = currentPosition[1];

      //second strategy
      for (int i = 0; i < file; i++) {
        if (currentRank - 1 < 0) break;

        final nextPiece = _getPiece([currentRank - 1, currentFile - 1]);

        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile - 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank - 1, currentFile - 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentRank--;
        currentFile--;
      }

      currentRank = currentPosition[0];
      currentFile = currentPosition[1];

      //third strategy
      for (int i = 0; i < 7; i++) {
        if (currentRank + 1 > 7) break;
        final nextPiece = _getPiece([currentRank + 1, currentFile + 1]);

        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile + 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile + 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentRank++;
        currentFile++;
      }

      currentRank = currentPosition[0];
      currentFile = currentPosition[1];

      //fourth strategy
      for (int i = 0; i < file; i++) {
        if (currentFile - 1 < 0) break;

        final nextPiece = _getPiece([currentRank + 1, currentFile - 1]);

        if (nextPiece == null) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile - 1],
            ),
          );
        } else if (pieceType != _getPieceType(nextPiece)) {
          validSquares.add(
            ArrayPosition.fromList(
              [currentRank + 1, currentFile - 1],
            ),
          );
          break;
        } else {
          break;
        }
        currentRank++;
        currentFile--;
      }
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
        file: targetPosition.file,
      );
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
              ArrayPosition.fromList([nextRank, file + 1]),
            );
          }
          final leftAdjacentPiece = _getPiece([nextRank, file - 1]);
          if (leftAdjacentPiece != null &&
              leftAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition.fromList([nextRank, file - 1]),
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
              ArrayPosition.fromList([nextRank, file - 1]),
            );
          }
          final leftAdjacentPiece = _getPiece([nextRank, file + 1]);
          if (leftAdjacentPiece != null &&
              leftAdjacentPiece.isWhite != isWhite) {
            validSquares.add(
              ArrayPosition.fromList([nextRank, file + 1]),
            );
          }
      }
    } catch (e) {}

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
              ArrayPosition.fromList([rank + 1, file]),
            );
          } else {
            return validSquares;
          }
          if (_getPiece([rank + 2, file]) == null) {
            validSquares.add(
              ArrayPosition.fromList([rank + 2, file]),
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
              ArrayPosition.fromList([rank - 1, file]),
            );
          } else {
            return validSquares;
          }
          if (_getPiece([rank - 2, file]) == null) {
            validSquares.add(
              ArrayPosition.fromList([rank - 2, file]),
            );
          }
          break;
        default:
          //if pawn is not on 7th ond 2nd rank, it can only move one square vertically

          if (isWhite) {
            //white pawns can only move one square up the board
            if (_getPiece([rank - 1, file]) == null) {
              validSquares.add(
                ArrayPosition.fromList([rank - 1, file]),
              );
            } else {
              return validSquares;
            }
          } else {
            //black pawns can only move one square down the board
            if (_getPiece([rank + 1, file]) == null) {
              validSquares.add(
                ArrayPosition.fromList([rank + 1, file]),
              );
            } else {
              return validSquares;
            }
          }
      }
    } catch (e) {}

    return validSquares;
  }

  List<ArrayPosition> _getValidKingMoves(
    List<int> currentPosition, {
    bool recursive = true,
  }) {
    List<ArrayPosition> validSquares = [];
    List<ArrayPosition> invalidSquares = [];
    final currentPos = ArrayPosition.fromList(currentPosition);
    final currentPieceType = _getPieceType(_getPiece(currentPosition)!);

    if (currentPieceType == PieceType.black && recursive) {
      invalidSquares = _getValidKingMoves(
        [_whiteKingPosition.rank, _whiteKingPosition.file],
        recursive: false,
      );
    }
    if (currentPieceType == PieceType.white && recursive) {
      invalidSquares = _getValidKingMoves(
        [_blackKingPosition.rank, _blackKingPosition.file],
        recursive: false,
      );
    }

    //left side
    final leftOffset = [currentPos.rank, currentPos.file - 1];
    final leftPiece = _getPiece(leftOffset);

    if ((leftPiece == null || currentPieceType != _getPieceType(leftPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(leftOffset))) {
      validSquares.add(ArrayPosition.fromList(leftOffset));
    }

    //right side
    final rightOffset = [currentPos.rank, currentPos.file + 1];
    final rightPiece = _getPiece(rightOffset);

    if ((rightPiece == null || currentPieceType != _getPieceType(rightPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(rightOffset))) {
      validSquares.add(ArrayPosition.fromList(rightOffset));
    }

    //top side
    final topOffset = [currentPos.rank + 1, currentPos.file];
    final topPiece = _getPiece(topOffset);

    if ((topPiece == null || currentPieceType != _getPieceType(topPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(topOffset))) {
      validSquares.add(ArrayPosition.fromList(topOffset));
    }

    //top-right side
    final topRightOffset = [currentPos.rank + 1, currentPos.file + 1];
    final topRightPiece = _getPiece(topRightOffset);

    if ((topRightPiece == null ||
            currentPieceType != _getPieceType(topRightPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(topRightOffset))) {
      validSquares.add(ArrayPosition.fromList(topRightOffset));
    }

    //top-left side
    final topLeftOffset = [currentPos.rank + 1, currentPos.file - 1];
    final topLeftPiece = _getPiece(topLeftOffset);

    if ((topLeftPiece == null ||
            currentPieceType != _getPieceType(topLeftPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(topLeftOffset))) {
      validSquares.add(ArrayPosition.fromList(topLeftOffset));
    }

    //bottom side
    final bottomOffset = [currentPos.rank - 1, currentPos.file];
    final bottomPiece = _getPiece(bottomOffset);

    if ((bottomPiece == null ||
            currentPieceType != _getPieceType(bottomPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(bottomOffset))) {
      validSquares.add(ArrayPosition.fromList(bottomOffset));
    }

    //bottom-right side
    final bottomRightOffset = [currentPos.rank - 1, currentPos.file + 1];
    final bottomRightPiece = _getPiece(bottomRightOffset);

    if ((bottomRightPiece == null ||
            currentPieceType != _getPieceType(bottomRightPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(bottomRightOffset))) {
      validSquares.add(ArrayPosition.fromList(bottomRightOffset));
    }

    //bottom-left side
    final bottomLeftOffset = [currentPos.rank - 1, currentPos.file - 1];
    final bottomLeftPiece = _getPiece(bottomLeftOffset);

    if ((bottomLeftPiece == null ||
            currentPieceType != _getPieceType(bottomLeftPiece)) &&
        !invalidSquares.contains(ArrayPosition.fromList(bottomLeftOffset))) {
      validSquares.add(ArrayPosition.fromList(bottomLeftOffset));
    }

    if (currentPieceType == PieceType.black) {
      validSquares.remove(_whiteKingPosition);
    } else {
      validSquares.remove(_blackKingPosition);
    }

    return validSquares;
  }

  ///Returns `true` if a king (black or white) is on [targetPosition].
  ///Otherwise, returns `false`.
  bool _isAttemptingToCaptureKing(ArrayPosition targetPosition) {
    return targetPosition == _blackKingPosition ||
        targetPosition == _whiteKingPosition;
  }

  @override
  void evaluateCheck(List<int> currentPosition, bool isWhite) {
    List<int> targetPosition;

    //if current piece is a white piece, grab position of the black king
    //otherwise, grab position of the white king and evaluate check
    if (isWhite) {
      targetPosition = [_blackKingPosition.rank, _blackKingPosition.file];
    } else {
      targetPosition = [_whiteKingPosition.rank, _whiteKingPosition.file];
    }
    Piece? king = _getPiece(targetPosition);

    if (king == null) return;

    final isChecked = evaluateValidMoves(currentPosition)
        .contains(ArrayPosition.fromList(targetPosition));

    print(
        "isChecked -> $isChecked, kingPos -> $targetPosition, isWhite -> $isWhite");

    _board.squares[targetPosition[0]][targetPosition[1]].piece =
        king.copyWith(isChecked: isChecked);
  }
}
