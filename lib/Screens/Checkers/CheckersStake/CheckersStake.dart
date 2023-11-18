import 'dart:convert';
import 'package:chekaz/Logics/Checkers/checkersPiece.dart';
import 'package:chekaz/Models/Source.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Logics/Chess/chess.dart';
import '../../../Providers/Websocket/WebsocketProvider.dart';
import '../../../Utility/colors.dart';
import '../components/CheckersSquare.dart';

class CheckersStake extends StatefulWidget {
  const CheckersStake({super.key});

  @override
  State<CheckersStake> createState() => _CheckersStakeState();
}

class _CheckersStakeState extends State<CheckersStake> {
  List<List<CheckersPiece?>> board = [];

  // valid moves for selected piece
  List<List<int>> validMoves = [];

  bool checkStatus = false;

  void pieceSelected(int row, int col, bool hasMandatoryCapture,
      bool isWhiteTurn, bool isLocalPlayerTurn) {
    setState(() {
      if (!isLocalPlayerTurn) {
        return;
      }

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
            movePiece(row, col, true, selecetedPiece!.isWhite);
          }
        } else {
          if (!hasMandatoryCapture) {
            movePiece(row, col, false, selecetedPiece!.isWhite);
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

  void movePiece(int newRow, int newCol, bool isKing, bool isWhite) {
    //remove the piece jumped if any from the board

    // Calculate the row and column difference
    int rowDiff = newRow - selecetedRow;
    int colDiff = newCol - selecetedCol;

    // Check if the move is a   normal capture move then check for more captures
    if (rowDiff.abs() == 2 && colDiff.abs() == 2) {
      // Capture move - remove the captured piece
      int capturedRow = (newRow + selecetedRow) ~/ 2;
      int capturedCol = (newCol + selecetedCol) ~/ 2;

      var source = Source(row: selecetedRow, col: selecetedCol);

      var destination = Destination(row: newRow, col: newCol);

      var captured =
          Captured(row: capturedRow, col: capturedCol, isWhite: isWhite);

      Provider.of<WebSocketProvider>(context, listen: false)
          .sendMove(source, destination, captured, isKing);

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

        // Check if there's an opponent's piece at the capture position
        if (board[capturedRow][capturedCol] != null) {
          if (board[capturedRow][capturedCol]!.isWhite !=
              selecetedPiece!.isWhite) {
            var captured =
                Captured(row: capturedRow, col: capturedCol, isWhite: isWhite);
            // Remove the captured opponent's piece
            board[capturedRow][capturedCol] = null;

            var source = Source(row: selecetedRow, col: selecetedCol);

            var destination = Destination(row: newRow, col: newCol);

            Provider.of<WebSocketProvider>(context, listen: false)
                .sendMove(source, destination, captured, isKing);
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
    }
    // normal move
    else {
      //promote to king if Possible

      makeKing(isKing);

      // Update the piece's row and column
      board[newRow][newCol] = selecetedPiece;
      board[selecetedRow][selecetedCol] = null;

      var source = Source(row: selecetedRow, col: selecetedCol);

      var destination = Destination(row: newRow, col: newCol);

      Provider.of<WebSocketProvider>(context, listen: false)
          .sendMove(source, destination, null, isKing);

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

    Provider.of<WebSocketProvider>(context, listen: false).changeTurn();
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
    // _initializeBoard();
    checkStatus = false;
    // whitePiecesCaptured.clear();
    // blackPiecesCaptured.clear();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use a Future-based approach to wait for the board initialization
    Future.delayed(Duration.zero, () {
      var newBoard =
          Provider.of<WebSocketProvider>(context, listen: false).board;

      setState(() {
        board = newBoard;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<WebSocketProvider>(context, listen: false).close();
  }

  CheckersPiece? selecetedPiece;
  //
  int selecetedRow = -1;

  //
  int selecetedCol = -1;

  bool? hasMandatoryCaptureForPiece(
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
    var isWhiteTurn = Provider.of<WebSocketProvider>(context).isWhiteTurn;

    bool isSignedIn = true;

    var isPlayer1 = Provider.of<WebSocketProvider>(context).isPlayer1;

    var blackPiecesCaptured =
        Provider.of<WebSocketProvider>(context).blackPiecesCaptured;

    var whitePiecesCaptured =
        Provider.of<WebSocketProvider>(context).whitePiecesCaptured;

    var loading = Provider.of<WebSocketProvider>(context).loading;

    var waitingP2 = Provider.of<WebSocketProvider>(context).waitingOpponent;

    var connected = Provider.of<WebSocketProvider>(context).isConnected;

    return Scaffold(
        backgroundColor: foregroundColor,
        body: isSignedIn == false
            ? const Center(
                child: Text("Create An Account To Play Staked Games"),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  waitingP2
                      ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 70,
                                  width: 80,
                                  child:
                                      Image.asset("assets/images/loader.gif")),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Waiting For Opponent")
                            ],
                          ),
                        )
                      : const SizedBox(),
                  loading && !connected && !waitingP2
                      ? const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(strokeWidth: 1),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Establishing Connection..'),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  !connected && !loading && !waitingP2
                      ? const Center(
                          child: Text('Select A Stake to Create Game Session '))
                      : const SizedBox(),
                  !connected && !loading && !waitingP2
                      ? Center(child: _buildStakeSelection())
                      : const SizedBox(),
                  connected && !loading && !waitingP2
                      ? Player2Container(
                          isWhiteTurn: isWhiteTurn,
                          whitePiecesCaptured: whitePiecesCaptured)
                      : const SizedBox(
                          height: 1,
                        ),
                  connected && !loading && !waitingP2
                      ? SizedBox(
                          width: double.infinity,
                          height: 400,
                          child: Transform.rotate(
                            angle: isPlayer1 ? 0 : 3.14159,
                            child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: 8 * 8,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 8),
                                itemBuilder: (ctx, index) {
                                  int row = index ~/ 8;
                                  int col = index % 8;
                                  // check if square is selected
                                  bool isSelected = selecetedRow == row &&
                                      selecetedCol == col;

                                  // check valid move
                                  bool validMove = false;

                                  for (var position in validMoves) {
                                    if (position[0] == row &&
                                        position[1] == col) {
                                      validMove = true;
                                    }
                                  }

                                  bool isLocallPlayer() {
                                    if (isPlayer1 && isWhiteTurn) {
                                      return true;
                                    } else if (!isPlayer1 && !isWhiteTurn) {
                                      return true;
                                    }

                                    return false;
                                  }

                                  bool? hasMandatoryCapture =
                                      hasMandatoryCaptureForPiece(
                                          row, col, board, isWhiteTurn);
                                  return CheckerSquare(
                                    isSelected: isSelected,
                                    isValidMove: validMove,
                                    isWhite: isWhite(index),
                                    piece: board[row][col],
                                    onTap: () {
                                      pieceSelected(
                                          row,
                                          col,
                                          hasMandatoryCapture ?? false,
                                          isWhiteTurn,
                                          isLocallPlayer());
                                    },
                                    hasMandatoryCapture:
                                        hasMandatoryCapture ?? false,
                                    isLocalPlayer: isLocallPlayer(),
                                  );
                                }),
                          ),
                        )
                      : const SizedBox(),
                  connected && !loading && !waitingP2
                      ? Player1Container(
                          blackPiecesCaptured: blackPiecesCaptured)
                      : const SizedBox(
                          height: 1,
                        ),
                ],
              ));
  }

  static const REQUEST_START = "START";
  static const PLAYER_MOVE = "MOVE"; //  player moves
  static const PLAYER_CAPTURE = "CAPTURE"; // New opcode for capturing pieces
  static const GAME_OVER_OP = "GAMEOVER"; // game over
  static const PLAYER_ONE_TURN = "0";
  static const PLAYER_TWO_TURN = "1";
  static const PLAYER_WAIT = "WAIT PLAYER2";
  static const CHANGE_TURN = "TURN";

  Widget _buildStakeSelection() {
    List<int> availableStakes = [
      50,
      100,
      250,
      300,
      400,
      500,
      750,
      1000,
      1500,
      2000,
      2500,
      3000,
      5000,
      7000,
      10000
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children:
              availableStakes.map((stake) => _buildStakeButton(stake)).toList(),
        ),
      ],
    );
  }

  Widget _buildStakeButton(int stake) {
    int availablePlayers = fetchAvailablePlayers(stake);

    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.blue,
      ),
      child: TextButton(
        onPressed: () {
          Provider.of<WebSocketProvider>(context, listen: false).connect(
              ctx: context,
              stake: stake,
              game: GameType.checkers,
              gameId: null);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ksh $stake',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              'Players: $availablePlayers',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  int fetchAvailablePlayers(int selectedStake) {
    Map<int, int> stakePendingPlayers = {
      50: 3,
      100: 1,
      200: 5,
      300: 0,
    };

    return stakePendingPlayers[selectedStake] ?? 0;
  }
}

class Player2Container extends StatelessWidget {
  const Player2Container({
    super.key,
    required this.isWhiteTurn,
    required this.whitePiecesCaptured,
  });

  final bool isWhiteTurn;
  final List<CheckersPiece?> whitePiecesCaptured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: Colors.black87,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage("assets/images/avatar.png"),
            radius: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          const Column(
            children: [
              Text(
                "Joe",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Icon(Icons.watch, color: Colors.white),
            ],
          ),
          const SizedBox(
            width: 30,
          ),
          Row(
            children: [
              const Text(
                "Current Turn",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 4),
                            blurRadius: 4)
                      ],
                      color: !isWhiteTurn ? Colors.orange : Colors.grey[100]))
            ],
          ),
          const Spacer(),
          Text(
            whitePiecesCaptured.length.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

class Player1Container extends StatelessWidget {
  const Player1Container({
    super.key,
    required this.blackPiecesCaptured,
  });

  final List<CheckersPiece?> blackPiecesCaptured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: Colors.black87,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage("assets/images/avatar.png"),
            radius: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bill",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.watch, color: Colors.white),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "0.59",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            blackPiecesCaptured.length.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
