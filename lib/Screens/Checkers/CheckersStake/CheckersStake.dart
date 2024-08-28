import 'dart:async';
import 'package:chekaz/Logics/Checkers/checkersPiece.dart';
import 'package:chekaz/Models/Source.dart';
import 'package:chekaz/Providers/Auth/CognitoAuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Logics/Chess/chess.dart';
import '../../../Models/Player.dart';
import '../../../Providers/Websocket/WebsocketProvider.dart';
import '../../../Utility/colors.dart';
import '../components/CheckersSquare.dart';

class CheckersStake extends StatefulWidget {
  const CheckersStake({super.key});

  @override
  State<CheckersStake> createState() => _CheckersStakeState();
}

class _CheckersStakeState extends State<CheckersStake> {
  Timer? turnTimer;

  void startTurnTimer() {
    turnTimer = Timer(const Duration(minutes: 1, seconds: 30), () {});
  }

  List<List<CheckersPiece?>> board = [];

  // valid moves for selected piece
  List<List<int>> validMoves = [];

  bool checkStatus = false;
  //
  void pieceSelected(int row, int col, bool hasMandatoryCapture,
      bool isWhiteTurn, bool isLocalPlayerTurn) {
    setState(() {
      if (!isLocalPlayerTurn) {
        print("=======NOT LOCAL PLAYER TURN");
        return;
      }

      print("=======LOCAL PLAYER TURN=======");
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
            movePiece(row, col, true, selecetedPiece!.isWhite, isWhiteTurn);
          }
        } else {
          if (!hasMandatoryCapture) {
            movePiece(row, col, false, selecetedPiece!.isWhite, isWhiteTurn);
          }
        }
      }

      validMoves =
          calculatevalidMoves(selecetedRow, selecetedCol, selecetedPiece);
    });
  }

  void handleGameOver() {
    print("GAME OVER=================");

    Provider.of<WebSocketProvider>(context, listen: false).gameOver();
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
        //backward right move

        //backward left move
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

  bool hasValidMoves(bool isWhiteTurn) {
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] != null &&
            board[row][col]!.isWhite == isWhiteTurn) {
          var validMoves = calculatevalidMoves(row, col, board[row][col]);
          if (validMoves.isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void movePiece(int newRow, int newCol, bool isKing, bool isWhite,
      bool isWhiteTurn) async {
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

      board[capturedRow][capturedCol] = null;

      int validMovesWhite = calculateAllValidMoves(true);
      print("Valid white moves*************** $validMovesWhite");
      int validMovesBlack = calculateAllValidMoves(false);
      print("Valid Black moves*************** $validMovesBlack");

      await Provider.of<WebSocketProvider>(context, listen: false).sendMove(
          source,
          destination,
          captured,
          isKing,
          validMovesWhite,
          validMovesBlack);

      board[selecetedRow][selecetedCol] = null;
      board[newRow][newCol] = selecetedPiece;

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

            int validMovesWhite = calculateAllValidMoves(true);

            int validMovesBlack = calculateAllValidMoves(false);

            await Provider.of<WebSocketProvider>(context, listen: false)
                .sendMove(source, destination, captured, isKing,
                    validMovesWhite, validMovesBlack);
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
        //
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

      int validMovesWhite = calculateAllValidMoves(true);

      int validMovesBlack = calculateAllValidMoves(false);

      await Provider.of<WebSocketProvider>(context, listen: false)
          .sendMove(source, destination, null, isKing, validMovesWhite,
              validMovesBlack)
          .then(
        (_) {
          changeTurn();
        },
      );
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
  void changeTurn() async {
    selecetedPiece = null;
    selecetedRow = -1;
    selecetedCol = -1;
    validMoves = [];

    await Provider.of<WebSocketProvider>(context, listen: false).changeTurn();
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

// This function calculates the total valid moves for a given player (white or black)
  int calculateAllValidMoves(bool isWhiteTurn) {
    int validMoveCount = 0;
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] != null &&
            board[row][col]!.isWhite == isWhiteTurn) {
          var validMoves = calculatevalidMoves(row, col, board[row][col]);
          validMoveCount += validMoves.length;
        }
      }
    }
    return validMoveCount;
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
    Future.delayed(const Duration(seconds: 1), () {
      var newBoard =
          Provider.of<WebSocketProvider>(context, listen: false).board;

      setState(() {
        board = newBoard;
      });
    });
  }

  CheckersPiece? selecetedPiece;
  //
  int selecetedRow = -1;

  //
  int selecetedCol = -1;

  bool? hasMandatoryCaptureForPiece(
      int row, int col, List<List<CheckersPiece?>> board, bool isWhiteTurn) {
    // board initialized
    if (row >= 0 && row < board.length && col >= 0 && col < board[row].length) {
      CheckersPiece? piece = board[row][col];

      if (piece != null && piece.isWhite == isWhiteTurn) {
        List<List<int>> captureMoves =
            calculatevalidCaptureMoves(row, col, piece);
        return captureMoves.isNotEmpty;
      }
    }
    return false;
  }

//

  @override
  Widget build(BuildContext context) {
    var isWhiteTurn = Provider.of<WebSocketProvider>(context).isWhiteTurn;

    bool isSignedIn = true;

    var isPlayer1 = Provider.of<WebSocketProvider>(context).isPlayer1;

    var localPlayer = Provider.of<WebSocketProvider>(context).localPlayer;

    var opponent = Provider.of<WebSocketProvider>(context).opponent;

    var blackPiecesCaptured =
        Provider.of<WebSocketProvider>(context).blackPiecesCaptured;

    var whitePiecesCaptured =
        Provider.of<WebSocketProvider>(context).whitePiecesCaptured;

    var loading = Provider.of<WebSocketProvider>(context).loading;

    var waitingP2 = Provider.of<WebSocketProvider>(context).waitingOpponent;

    var connected = Provider.of<WebSocketProvider>(context).isConnected;

    bool isLocallPlayer() {
      if (isPlayer1 && isWhiteTurn) {
        return true;
      } else if (!isPlayer1 && !isWhiteTurn) {
        return true;
      }

      return false;
    }

    Future<bool> onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Game'),
              content: const Text(
                  'Are you sure you want to exit the game? Your progress will be lost.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pop(false), // Dismiss the dialog and stay on the page
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // send disconnect event
                    Provider.of<WebSocketProvider>(context, listen: false)
                        .forfeit();
                    //
                    Navigator.of(context).pop(true);
                  }, // Close the dialog and exit the page
                  child: const Text('Yes'),
                ),
              ],
            ),
          )) ??
          false; // If the user dismisses the dialog by tapping outside of it, stay on the page
    }

    return WillPopScope(
      onWillPop: connected && !loading && !waitingP2 ? onWillPop : null,
      child: Scaffold(
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
                                    child: Image.asset(
                                        "assets/images/loader.gif")),
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
                            child:
                                Text('Select A Stake to Create Game Session '))
                        : const SizedBox(),
                    !connected && !loading && !waitingP2
                        ? Center(child: _buildStakeSelection())
                        : const SizedBox(),
                    connected && !loading && !waitingP2
                        ? Column(
                            children: [
                              isPlayer1
                                  ? Player2Container(
                                      player: opponent!,
                                      isWhiteTurn: isWhiteTurn,
                                      whitePiecesCaptured: whitePiecesCaptured)
                                  : Player1Container(
                                      player: opponent!,
                                      isWhiteTurn: isWhiteTurn,
                                      blackPiecesCaptured: whitePiecesCaptured),
                              SizedBox(
                                width: double.infinity,
                                child: Transform.rotate(
                                  angle: isPlayer1 ? 0 : 3.14159,
                                  child: Column(
                                    children: [
                                      GridView.builder(
                                          shrinkWrap: true,
                                          itemCount: 8 * 8,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 8),
                                          itemBuilder: (ctx, index) {
                                            int row = index ~/ 8;
                                            int col = index % 8;
                                            // check if square is selected
                                            bool isSelected =
                                                selecetedRow == row &&
                                                    selecetedCol == col;

                                            // check valid move
                                            bool validMove = false;

                                            for (var position in validMoves) {
                                              if (position[0] == row &&
                                                  position[1] == col) {
                                                validMove = true;
                                              }
                                            }

                                            bool? hasMandatoryCapture =
                                                hasMandatoryCaptureForPiece(row,
                                                    col, board, isWhiteTurn);

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
                                                  isLocallPlayer(),
                                                );
                                              },
                                              hasMandatoryCapture:
                                                  hasMandatoryCapture ?? false,
                                              isLocalPlayer: isLocallPlayer(),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              isPlayer1
                                  ? Player1Container(
                                      blackPiecesCaptured: blackPiecesCaptured,
                                      isWhiteTurn: isWhiteTurn,
                                      player: localPlayer!,
                                    )
                                  : Player2Container(
                                      whitePiecesCaptured: whitePiecesCaptured,
                                      isWhiteTurn: isWhiteTurn,
                                      player: localPlayer!,
                                    ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                )),
    );
  }

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
    var user = Provider.of<CognitoAuthProvider>(context).user;

    int availablePlayers = fetchAvailablePlayers(stake);

    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.black87,
      ),
      child: TextButton(
        onPressed: () {
          Provider.of<WebSocketProvider>(context, listen: false).connect(
              ctx: context,
              stake: stake,
              game: GameType.checkers,
              gameId: null,
              user: user!);
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

class Player1Container extends StatefulWidget {
  const Player1Container(
      {Key? key,
      required this.blackPiecesCaptured,
      required this.player,
      required this.isWhiteTurn})
      : super(key: key);

  final List<CheckersPiece?> blackPiecesCaptured;
  final bool isWhiteTurn;
  final Player player;
  @override
  _Player1ContainerState createState() => _Player1ContainerState();
}

class _Player1ContainerState extends State<Player1Container> {
  late Timer turnTimer;
  late Duration remainingTime = const Duration(minutes: 1, seconds: 30);

  @override
  void initState() {
    super.initState();
    if (widget.isWhiteTurn) {
      startTurnTimer();
    }
  }

  @override
  void dispose() {
    turnTimer.cancel();
    super.dispose();
  }

  void startTurnTimer() {
    turnTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - const Duration(seconds: 1);
        } else {
          // Handle the expiration of the timer, possibly end the turn or take some action.
        }
      });
    });
  }

  void resetTurnTimer() {
    turnTimer.cancel();
    setState(() {
      remainingTime = const Duration(minutes: 1, seconds: 30);
    });
    if (widget.isWhiteTurn) {
      startTurnTimer();
    }
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.player.name,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.watch, color: Colors.white),
                  const SizedBox(
                    width: 5,
                  ),
                  if (widget.isWhiteTurn)
                    Text(
                      '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.blackPiecesCaptured.length.toString(),
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

class Player2Container extends StatefulWidget {
  const Player2Container({
    Key? key,
    required this.isWhiteTurn,
    required this.player,
    required this.whitePiecesCaptured,
  }) : super(key: key);

  final bool isWhiteTurn;
  final List<CheckersPiece?> whitePiecesCaptured;
  final Player player;
  @override
  _Player2ContainerState createState() => _Player2ContainerState();
}

class _Player2ContainerState extends State<Player2Container> {
  late Timer turnTimer;
  late Duration remainingTime = const Duration(minutes: 1, seconds: 30);

  @override
  void initState() {
    super.initState();
    if (!widget.isWhiteTurn) {
      startTurnTimer();
    }
  }

  @override
  void dispose() {
    turnTimer.cancel();
    super.dispose();
  }

  void startTurnTimer() {
    turnTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - const Duration(seconds: 1);
        } else {
          // Handle the expiration of the timer, possibly end the turn or take some action.
        }
      });
    });
  }

  void resetTurnTimer() {
    turnTimer.cancel();
    setState(() {
      remainingTime = const Duration(minutes: 1, seconds: 30);
    });
    if (!widget.isWhiteTurn) {
      startTurnTimer();
    }
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.player.name,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.watch, color: Colors.white),
                  const SizedBox(
                    width: 5,
                  ),
                  if (!widget.isWhiteTurn)
                    Text(
                      '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
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
                      blurRadius: 4,
                    )
                  ],
                  color: !widget.isWhiteTurn ? Colors.orange : Colors.grey[100],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.whitePiecesCaptured.length.toString(),
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
