import 'package:flutter/widgets.dart';

class CheckersLogic extends ChangeNotifier {
  late List<List<int>> board;
  late int turn;
  late int winner;
  late List<List<int>> moves;
  late List<List<int>> jumps;

  CheckersLogic() {
    board = List.generate(8, (_) => List.filled(8, 0));
    for (int i = 0; i < 8; i++) {
      for (int j = i % 2; j < 8; j += 2) {
        if (i < 3) {
          board[i][j] = 2; // White piece
        } else if (i > 4) {
          board[i][j] = 1; // Black piece
        }
      }
    }
    turn = 1;
    winner = 0;
    moves = [];
    jumps = [];
    updateMoves();
    updateJumps();
  }

  void updateMoves() {
    moves.clear();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == turn || board[i][j] == turn + 2) {
          bool isKing = board[i][j] > 2;
          for (int di = -1; di <= 1; di += 2) {
            for (int dj = -1; dj <= 1; dj += 2) {
              if (isKing || di == (turn == 1 ? -1 : 1)) {
                int ni = i + di;
                int nj = j + dj;
                if (ni >= 0 &&
                    ni < 8 &&
                    nj >= 0 &&
                    nj < 8 &&
                    board[ni][nj] == 0) {
                  moves.add([i, j, ni, nj]);
                }
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  void updateJumps() {
    jumps.clear();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == turn || board[i][j] == turn + 2) {
          bool isKing = board[i][j] > 2;
          for (int di = -1; di <= 1; di += 2) {
            for (int dj = -1; dj <= 1; dj += 2) {
              if (isKing || di == (turn == 1 ? -1 : 1)) {
                int mi = i + di;
                int mj = j + dj;
                if (mi >= 0 &&
                    mi < 8 &&
                    mj >= 0 &&
                    mj < 8 &&
                    board[mi][mj] > 0 &&
                    board[mi][mj] != turn &&
                    board[mi][mj] != turn + 2) {
                  int ni = mi + di;
                  int nj = mj + dj;
                  if (ni >= 0 &&
                      ni < 8 &&
                      nj >= 0 &&
                      nj < 8 &&
                      board[ni][nj] == 0) {
                    jumps.add([i, j, mi, mj, ni, nj]);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    bool isJump = (fromRow - toRow).abs() == 2 && (fromCol - toCol).abs() == 2;
    return (isJump ? jumps : moves).any((move) =>
        move[0] == fromRow &&
        move[1] == fromCol &&
        move[2] == toRow &&
        move[3] == toCol);
  }

  void makeMove(List<int> move) {
    int fromRow = move[0];
    int fromCol = move[1];
    int toRow = move[2];
    int toCol = move[3];

    board[toRow][toCol] = board[fromRow][fromCol];
    board[fromRow][fromCol] = 0;

    if (isJump(move)) {
      int capturedRow = move[4];
      int capturedCol = move[5];
      board[capturedRow][capturedCol] = 0;
    }

    if (toRow == 0 || toRow == 7) {
      if (board[toRow][toCol] == 1) {
        board[toRow][toCol] = 3; // Promote to king (black)
      } else if (board[toRow][toCol] == 2) {
        board[toRow][toCol] = 4; // Promote to king (white)
      }
    }

    turn = 3 - turn;
    updateMoves();
    updateJumps();
    checkForWin();
  }

  bool isJump(List<int> move) {
    return (move[0] - move[2]).abs() == 2 && (move[1] - move[3]).abs() == 2;
  }

  void checkForWin() {
    bool currentPlayerPiecesLeft = false;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == turn || board[i][j] == turn + 2) {
          currentPlayerPiecesLeft = true;
        }
      }
    }
    if (!currentPlayerPiecesLeft) {
      winner = 3 - turn;
    }
  }
}
