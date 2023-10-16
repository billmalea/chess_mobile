import 'package:flutter/material.dart';

import '../../Logics/Chess/chess.dart';
import '../../Logics/Chess/chesspiece.dart';
import '../../Utility/colors.dart';
import 'components/deadpiece.dart';
import 'components/square.dart';

class ChessGameBoard extends StatefulWidget {
  const ChessGameBoard({super.key});

  @override
  State<ChessGameBoard> createState() => _ChessGameBoardState();
}

class _ChessGameBoardState extends State<ChessGameBoard> {
  List<ChessPiece?> whitePiecesCaptured = [];

  List<ChessPiece?> blackPiecesCaptured = [];

  late List<List<ChessPiece?>> board = [];

  ///turns
  bool isWhiteTurn = true;

  //kings positions
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  // valid moves for selected piece
  List<List<int>> validMoves = [];

  bool checkStatus = false;

  void pieceSelected(int row, int col) {
    setState(() {
      //No piece has been selected yet this is the first selection
      if (selecetedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selecetedPiece = board[row][col];
          selecetedCol = col;
          selecetedRow = row;
        }
      }

      /// there is a piece already selected but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selecetedPiece!.isWhite) {
        selecetedPiece = board[row][col];
        selecetedCol = col;
        selecetedRow = row;
      }
      //if theres a  piece selected and user taps on a square that is a valid move there
      else if (selecetedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves =
          realValidMoves(selecetedRow, selecetedCol, selecetedPiece, true);
    });
  }

// calculate raw valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> possibleMoves = [];
    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          possibleMoves.add([row + direction, col]);
        }
        //pawns can move 2 squares forward if they are at their initial positions.
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            possibleMoves.add([row + 2 * direction, col]);
          }
        }

        //pawns can kill diagonally

        //capture moving left diagonally

        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          possibleMoves.add([row + direction, col - 1]);
        }

        //capture  moving right diagonally
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          possibleMoves.add([row + direction, col + 1]);
        }

        break;

      case ChessPieceType.rook:
        // horizontal and vertical movements
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1] //right
        ];
        for (var dir in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * dir[0];
            var newCol = row + i * dir[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                possibleMoves.add([newRow, newCol]); // capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:

        // knight movements
        var knightMoves = [
          [-2, -1], //up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], //up 1 left2
          [-1, 2], //up 1 right 2
          [1, -2], //down 1 left 2
          [1, 2], //down 1 right 2
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              possibleMoves.add([newRow, newCol]); //capture
            }
            continue;
          }
          possibleMoves.add([newRow, newCol]);
        }
        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1] //down right
        ];
        for (var dir in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * dir[0];
            var newCol = col + i * dir[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                possibleMoves.add([newRow, newCol]); //capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        // queen has four directions up, down,left,right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], // right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var dir in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * dir[0];
            var newCol = row + i * dir[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                possibleMoves.add([newRow, newCol]); // capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // king has four directions up, down,left,right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], // right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var dir in directions) {
          var newRow = row * dir[0];
          var newCol = row * dir[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              possibleMoves.add([newRow, newCol]); // capture
            }
            continue;
          }
          possibleMoves.add([newRow, newCol]);
        }

        break;

      default:
    }

    return possibleMoves;
  }

  movePiece(int newRow, int newCol) {
    // if new spot has opponents piece
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesCaptured.add(capturedPiece);
      } else {
        blackPiecesCaptured.add(capturedPiece);
      }
    }
    //check if the piece being moved is king
    if (selecetedPiece!.type == ChessPieceType.king) {
      if (selecetedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    //move piece and clear old spot
    board[newRow][newCol] = selecetedPiece;
    board[selecetedRow][selecetedCol] = null;

    // see if any king is under attack
    if (isKingInCheck(isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection

    setState(() {
      selecetedPiece = null;
      selecetedRow = -1;
      selecetedCol = -1;
      validMoves = [];
    });

    // check if its check mate

    if (isCheckMate(isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('CHECKMATE'),
                actions: [
                  TextButton(onPressed: replay, child: const Text('Play Again'))
                ],
              ));
    }

    // change turns

    isWhiteTurn = !isWhiteTurn;
  }

  List<List<int>> realValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> validMoves = [];
    List<List<int>> possibleMoves = calculateRawValidMoves(row, col, piece);
    // filter any move that woud result in a check
    if (checkSimulation) {
      for (var move in possibleMoves) {
        int endRow = move[0];
        int endCol = move[1];

        //simulate future move to see if its safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          validMoves.add(move);
        }
      }
    } else {
      validMoves = possibleMoves;
    }

    return validMoves;
  }

//simulate future move if safe

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
// save current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

//if piece is the king, save its current position and update to the new one.
    List<int>? originalKingPosition;

    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      // update king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    // simulate the move

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);
    //restore board to original state

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;
    // if the piece was the king restore its original position
    if (piece.type == ChessPieceType.king) {
      whiteKingPosition = originalKingPosition!;
    } else {
      blackKingPosition = originalKingPosition!;
    }

    return !kingInCheck;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    //check if any piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip  empty squares and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            realValidMoves(i, j, board[i][j], false);
        // check if he kings position is in this piece's valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCheckMate(bool isWhiteKing) {
// if king is not in check, then its not check maten
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

//if theres atleast one legal move any of the player s pieces then its not check mate

    for (int i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        // skip empty squares and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            realValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  void replay() {
    Navigator.of(context).pop();
    _initializeBoard();
    checkStatus = false;
    whitePiecesCaptured.clear();
    blackPiecesCaptured.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  ChessPiece? selecetedPiece;
  //
  int selecetedRow = -1;

  //
  int selecetedCol = -1;

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(
        8,
        (index) => List.generate(
              8,
              (index) => null,
            ));

    //pawns
    for (var i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'assets/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'assets/images/pawn.png');
    }

    //rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/images/rook.png');

    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/images/rook.png');

    //knights

    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/images/knight.png');

    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/images/knight.png');

    //bishop

    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/images/bishop.png');

    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/images/bishop.png');

    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/images/bishop.png');
    //queens

    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/images/queen.png');

    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/images/queen.png');

    //kings

    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/images/king.png');

    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'assets/images/king.png');

    board = newBoard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: whitePiecesCaptured.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        imagePath: whitePiecesCaptured[index]!.imagePath,
                        isWhite: true,
                      ))),
          Text(checkStatus ? 'CHECK' : ""),
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (ctx, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  // check if square is selected
                  bool isSelected = selecetedRow == row && selecetedCol == col;
                  // check valid move
                  bool validMove = false;

                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      validMove = true;
                    }
                  }
                  return Square(
                    isSelected: isSelected,
                    isValidMove: validMove,
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    onTap: () => pieceSelected(row, col),
                  );
                }),
          ),
          Expanded(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: whitePiecesCaptured.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                        imagePath: whitePiecesCaptured[index]!.imagePath,
                        isWhite: false,
                      ))),
        ],
      ),
    );
  }
}
