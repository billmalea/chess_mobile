import 'dart:convert';
import 'package:chekaz/Logics/Checkers/checkersPiece.dart';
import 'package:chekaz/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Logics/Chess/chess.dart';
import '../../../Utility/colors.dart';
import '../components/CheckersSquare.dart';

class CheckersOfflineMultiplayer extends StatefulWidget {
  const CheckersOfflineMultiplayer({super.key});

  @override
  State<CheckersOfflineMultiplayer> createState() =>
      _CheckersOfflineMultiplayerState();
}

class _CheckersOfflineMultiplayerState
    extends State<CheckersOfflineMultiplayer> {
  List<CheckersPiece?> whitePiecesCaptured = [];

  List<CheckersPiece?> blackPiecesCaptured = [];

  late List<List<CheckersPiece?>> board = [];

  ///turns
  bool isWhiteTurn = true;

  // valid moves for selected piece
  List<List<int>> validMoves = [];

  bool checkStatus = false;

  void pieceSelected(int row, int col, bool hasMandatoryCapture) {
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
        //promote to king if its in the last row
        int lastRow = selecetedPiece!.isWhite ? 0 : 7;
        if (row == lastRow) {
          if (!hasMandatoryCapture) {
            movePiece(row, col, true);
          }
        } else {
          if (!hasMandatoryCapture) {
            movePiece(row, col, false);
          }
        }
      }

      validMoves =
          calculatevalidMoves(selecetedRow, selecetedCol, selecetedPiece);
    });
  }

  List<List<int>> calculatevalidMoves(int row, int col, CheckersPiece? piece) {
    List<List<int>> possibleMoves = [];
    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    if (piece.type == CheckersPieceType.normal) {
      final capturemoves = calculatevalidCaptureMoves(row, col, piece);

      //a capture move is mandatory
      if (capturemoves.isEmpty) {
        // Forward-left move
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] == null) {
          possibleMoves.add([row + direction, col - 1]);
        }

        // Forward-right move
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] == null) {
          possibleMoves.add([row + direction, col + 1]);
        }
      }

      //if there are capture moves show the moves

      else if (capturemoves.isNotEmpty) {
        possibleMoves.addAll(capturemoves);
      }
    }

    // King movements
    else {
      // All four possible directions for a king
      List<List<int>> directions = [
        [-1, -1], // Backward-left
        [-1, 1], // Backward-right
        [1, -1], // Forward-left
        [1, 1] // Forward-right
      ];

      for (List<int> dir in directions) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];

        // Capture move

        final capturemoves = calculatevalidCaptureMoves(row, col, piece);

        //a capture move is mandatory
        if (capturemoves.isEmpty) {
          // Normal move
          if (isInBoard(newRow, newCol) && board[newRow][newCol] == null) {
            possibleMoves.add([newRow, newCol]);
          }
        }

        //if there are capture moves only  show the moves

        else if (capturemoves.isNotEmpty) {
          possibleMoves.addAll(capturemoves);
        }
      }
    }
    return possibleMoves;
  }

  void movePiece(int newRow, int newCol, bool isKing) {
    //remove the piece jumped if any from the board

    // Calculate the row and column difference
    int rowDiff = newRow - selecetedRow;
    int colDiff = newCol - selecetedCol;

    // Check if the move is a   normal capture move then check for more captures
    if (rowDiff.abs() == 2 && colDiff.abs() == 2) {
      // Capture move - remove the captured piece
      int capturedRow = (newRow + selecetedRow) ~/ 2;
      int capturedCol = (newCol + selecetedCol) ~/ 2;

      board[selecetedRow][selecetedCol] = null;
      board[newRow][newCol] = selecetedPiece;
      board[capturedRow][capturedCol] = null;

      // Check if there are additional moves for the current player
      List<List<int>> additionalMoves =
          calculatevalidCaptureMoves(newRow, newCol, selecetedPiece);

      //promote to king if Possible
      makeKing(isKing);

      if (additionalMoves.isNotEmpty) {
        // The current player has more moves, allow them to continue
        selecetedRow = newRow;
        selecetedCol = newCol;
        validMoves = additionalMoves;
      } else {
        changeTurn();
      }

      ////////
      // check for kings long diagonal jump
      ////////////
    } else if (rowDiff.abs() > 2 && colDiff.abs() > 2) {
      print("Long diagonal capture activate");

      int capturedRow = newRow;
      int capturedCol = newCol;

      while (capturedRow != selecetedRow && capturedCol != selecetedCol) {
        capturedRow -= (newRow - selecetedRow).sign;
        capturedCol -= (newCol - selecetedCol).sign;

        // Check if there's an opponent's piece at the captured position
        if (board[capturedRow][capturedCol] != null) {
          if (board[capturedRow][capturedCol]!.isWhite !=
              selecetedPiece!.isWhite) {
            // Remove the captured opponent's piece
            board[capturedRow][capturedCol] = null;
          } else {
            // Stop capturing if you encounter your own piece
            break;
          }
        }
      }
      //promote to king if Possible
      makeKing(isKing);

      board[newRow][newCol] = selecetedPiece;

      board[selecetedRow][selecetedCol] = null;

      // Check if there are additional moves for the current player
      List<List<int>> additionalMoves =
          calculatevalidCaptureMoves(newRow, newCol, selecetedPiece);

      if (additionalMoves.isNotEmpty) {
        // The current player has more moves, allow them to continue
        selecetedRow = newRow;
        selecetedCol = newCol;
        validMoves = additionalMoves;
      } else {
        changeTurn();
      }
    } else {
      //promote to king if Possible

      makeKing(isKing);

      // Update the piece's row and column
      board[newRow][newCol] = selecetedPiece;
      board[selecetedRow][selecetedCol] = null;

      changeTurn();
    }
  }

//promote to king

// change turns
  void makeKing(bool isKing) {
    if (isKing) {
      selecetedPiece!.type = CheckersPieceType.king;
    }
  }

// change turns
  void changeTurn() {
    selecetedPiece = null;
    selecetedRow = -1;
    selecetedCol = -1;
    validMoves = [];

    isWhiteTurn = !isWhiteTurn;
  }

//calculate valid capture moves for boh normal and king piece
  List<List<int>> calculatevalidCaptureMoves(
      int row, int col, CheckersPiece? piece) {
    List<List<int>> captureMoves = [];
    if (piece == null) {
      return captureMoves;
    }
    int direction = piece.isWhite ? -1 : 1;
    // Check for capture moves for a normal piece
    if (piece.type == CheckersPieceType.normal) {
      // Forward-right capture
      if (isInBoard(row + 2 * direction, col + 2) &&
          board[row + direction][col + 1] != null &&
          board[row + direction][col + 1]!.isWhite != piece.isWhite &&
          board[row + 2 * direction][col + 2] == null) {
        captureMoves.add([row + 2 * direction, col + 2]);
      }

      // Forward-left capture
      if (isInBoard(row + 2 * direction, col - 2) &&
          board[row + direction][col - 1] != null &&
          board[row + direction][col - 1]!.isWhite != piece.isWhite &&
          board[row + 2 * direction][col - 2] == null) {
        captureMoves.add([row + 2 * direction, col - 2]);
      }
    }

    // Check for capture moves for a king piece
    else if (piece.type == CheckersPieceType.king) {
      // All four possible directions for a king
      List<List<int>> directions = [
        [-1, -1], // Backward-left
        [-1, 1], // Backward-right
        [1, -1], // Forward-left
        [1, 1] // Forward-right
      ];

      for (List<int> dir in directions) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];

        // Continue along the path until an opponent's piece is found
        while (isInBoard(newRow, newCol) && board[newRow][newCol] == null) {
          newRow += dir[0];
          newCol += dir[1];
        }

        // Capture move
        if (isInBoard(newRow + dir[0], newCol + dir[1]) &&
            board[newRow][newCol] != null &&
            board[newRow][newCol]!.isWhite != piece.isWhite &&
            board[newRow + dir[0]][newCol + dir[1]] == null) {
          captureMoves.add([newRow + dir[0], newCol + dir[1]]);
        }
      }
    }

    return captureMoves;
  }

  void replay() {
    Navigator.of(context).pop();
    _initializeBoard();
    checkStatus = false;
    whitePiecesCaptured.clear();
    blackPiecesCaptured.clear();

    isWhiteTurn = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  CheckersPiece? selecetedPiece;
  //
  int selecetedRow = -1;

  //
  int selecetedCol = -1;

  void _initializeBoard() {
    List<List<CheckersPiece?>> newBoard = List.generate(
      8,
      (row) => List.generate(
        8,
        (col) {
          if ((row + col) % 2 == 1) {
            if (row < 3) {
              return CheckersPiece(
                  isWhite: false, type: CheckersPieceType.normal);
            } else if (row > 4) {
              return CheckersPiece(
                  isWhite: true, type: CheckersPieceType.normal);
            }
          }
          return null;
        },
      ),
    );

    // Assign the new board to the class variable
    board = newBoard;
  }

  bool hasMandatoryCaptureForPiece(
      int row, int col, List<List<CheckersPiece?>> board, bool isWhiteTurn) {
    CheckersPiece? piece = board[row][col];
    if (piece != null && piece.isWhite == isWhiteTurn) {
      List<List<int>> captureMoves =
          calculatevalidCaptureMoves(row, col, piece);
      return captureMoves.isNotEmpty;
    }
    return false;
  }

//

  @override
  Widget build(BuildContext context) {
    const gameStarted = false;

    return Scaffold(
        backgroundColor: foregroundColor,
        body: Column(
          children: [
            Text(checkStatus ? 'CHECK' : ""),
            Expanded(
              flex: 5,
              child: GridView.builder(
                  itemCount: 8 * 8,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (ctx, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    // check if square is selected
                    bool isSelected =
                        selecetedRow == row && selecetedCol == col;

                    // check valid move
                    bool validMove = false;

                    for (var position in validMoves) {
                      if (position[0] == row && position[1] == col) {
                        validMove = true;
                      }
                    }

                    bool hasMandatoryCapture = hasMandatoryCaptureForPiece(
                        row, col, board, isWhiteTurn);
                    return CheckerSquare(
                      isSelected: isSelected,
                      isValidMove: validMove,
                      isWhite: isWhite(index),
                      piece: board[row][col],
                      onTap: () {
                        pieceSelected(row, col, hasMandatoryCapture);
                      },
                      hasMandatoryCapture: hasMandatoryCapture,
                      isLocalPlayer: false,
                    );
                  }),
            ),
            Expanded(
                child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: whitePiecesCaptured.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemBuilder: (context, index) =>
                        Text(blackPiecesCaptured.length.toString()))),
          ],
        )); // Your game UI widget goes here.
  }
}
