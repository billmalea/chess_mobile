// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:chekaz/Utility/ToastItems.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../Logics/Checkers/checkersPiece.dart';
import '../../Models/Player.dart';
import '../../Models/Source.dart';
import '../../Utility/SnackMessage.dart';

enum GameType { checkers, chess }

class WebSocketProvider with ChangeNotifier {
  Future<void> _initializeBoard(bool isWhite) async {
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
    _board = newBoard;
  }

  List<CheckersPiece?> get whitePiecesCaptured => _whitePiecesCaptured;

  // ignore: prefer_final_fields
  List<CheckersPiece?> _whitePiecesCaptured = [];

  List<CheckersPiece?> get blackPiecesCaptured => _blackPiecesCaptured;

  // ignore: prefer_final_fields
  List<CheckersPiece?> _blackPiecesCaptured = [];

  List<List<CheckersPiece?>> get board => _board;

  List<List<CheckersPiece?>> _board = [];

  final serverUrl =
      "wss://mx84dv6j1a.execute-api.us-east-1.amazonaws.com/Prod/";

  Player? get localPlayer => _localPlayer;

  Player? get opponent => _opponent;

  String get gameId => _gameId;

  Player? _localPlayer;

  bool _isPlayer1 = false;

  String _gameId = "";

  Player? _opponent;

  WebSocketChannel? _channel;

  bool _isConnected = false;

  bool _waitingOpponent = false;

  bool get waitingOpponent => _waitingOpponent;

  bool get loading => _isLoading;

  bool get isWhiteTurn => _isWhiteTurn;

  bool get isPlayer1 => _isPlayer1;

  bool _isLoading = false;

  bool _isWhiteTurn = false;

  final StreamController<dynamic> _messageStreamController =
      StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageStreamController.stream;

  bool get isConnected => _isConnected;

  Future<IOWebSocketChannel> websocketconnect(
      int? stake, GameType game, String? gameId, AuthUser user) async {
    dynamic header() {
      if (stake != null) {
        return {
          "stake": stake,
          "gametype": game == GameType.checkers ? "checkers" : "chess",
          "username": user.username,
          "userId": user.userId
        };
      } else {
        return {
          "gametype": game == GameType.checkers ? "checkers" : "chess",
          "username": user.username,
          "userId": user.userId,
        };
      }
    }

    final socket = await WebSocket.connect(serverUrl, headers: header());

    return IOWebSocketChannel(socket);
  }

  Future<void> connect(
      {required BuildContext ctx,
      required int? stake,
      required GameType game,
      required String? gameId,
      required AuthUser user}) async {
    try {
      if (_isConnected) {
        return;
      }

      _isLoading = true;

      notifyListeners();

      _channel = await websocketconnect(stake, game, gameId, user);

      _channel!.stream.listen(
        (message) {
          print(message);
          handleWebsocketmessage(message);
          _messageStreamController.add(message);
          notifyListeners();
        },
        onError: (e) {
          print("websocket error################ $e");

          _isConnected = false;

          _isLoading = false;

          notifyListeners();

          snackmessage("An Error Occured", ctx);
        },
        onDone: () {
          handleDisconnect();

          snackmessage("Disconnected", ctx);
        },
        cancelOnError: true,
      );
    } on TimeoutException {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Connection timed out.Please Try again.')),
      );
    } on SocketException {
      _isLoading = false;

      notifyListeners();

      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Check Your Internet Connection and Try Again')),
      );
    } on WebSocketException {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Websocket Connection Errors')),
      );
    } catch (e) {
      print("****************$e");
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Connection Errors')),
      );
    }
  }

  // Send a message over the WebSocket
  void sendMessage(dynamic message, BuildContext ctx) {
    try {
      if (_isConnected) {
        _channel!.sink.add(jsonEncode(message));
      }
    } on SocketException {
      snackmessage("No internet connection ", ctx);
    } catch (e) {
      print(
          "____________________********SEND WEBSOCKET MESSAGE ERROR************ ____________-");
    }
  }

  void gameOver() {
    var message = {
      "action": "notification",
      "operation": GAME_OVER,
      "gameId": _gameId,
      "playerId": localPlayer!.userId,
    };
    try {
      if (_isConnected) {
        _channel!.sink.add(jsonEncode(message));
      }
    } on SocketException {
      errortoast("NO INTERNET CONNECTION");
    } catch (e) {
      print(
          "____________________********SEND WEBSOCKET MESSAGE ERROR************ ____________-");
    }
  }

  // Send a message over the WebSocket
  void sendMove(Source source, Destination destination, Captured? captured,
      bool isKing, int validmovesp1, int validmovesp2) {
    final data = {
      "action": "notification",
      "operation": PLAYER_MOVE,
      "turn": isWhiteTurn ? PLAYER_ONE_TURN : PLAYER_TWO_TURN,
      "gameId": gameId,
      "isKing": isKing,
      'validmovesp1': validmovesp1,
      'validmovesp2': validmovesp2,
      "opponentId": opponent!.userId,
      "move": {
        "source": {"row": source.row, "col": source.col},
        "destination": {"row": destination.row, "col": destination.col}
      },
      "captured": captured != null
          ? {
              "isWhite": captured.isWhite,
              "col": captured.col,
              "row": captured.row,
            }
          : null,
    };

    _channel!.sink.add(jsonEncode(data));
  }

  // Send a message over the WebSocket
  void changeTurn() {
    final data = {
      "action": "notification",
      "operation": CHANGE_TURN,
      "turn": _isWhiteTurn ? PLAYER_TWO_TURN : PLAYER_ONE_TURN,
      "gameId": gameId,
    };

    _isWhiteTurn = !_isWhiteTurn;

    notifyListeners();

    _channel!.sink.add(jsonEncode(data));
  }

  // Close the WebSocket connection
  void close() {
    _isConnected = false;

    _waitingOpponent = false;

    //
    _isLoading = false;
    //

    final data = {"action": "disconnect", "gameId": _gameId};

    _channel!.sink.add(jsonEncode(data));
  }

  void forfeit() async {
    _isConnected = false;

    _waitingOpponent = false;

    //
    _isLoading = false;
    //

    final data = {"action": "notification", "operation": PLAYER_FORFEIT};

    _channel!.sink.add(jsonEncode(data));
  }

  void timeout() {
    _isConnected = false;

    _waitingOpponent = false;

    //
    _isLoading = false;
    //
    final data = {"action": "notification", "operation": OPPONENT_TIMEOUT};

    _channel!.sink.add(jsonEncode(data));
  }

  handleWebsocketmessage(dynamic data) {
    var message = jsonDecode(data);

    switch (message['operation']) {
      case PLAYER_WAIT:
        //
        _waitingOpponent = true;

        //
        _isLoading = false;
        //

        _gameId = message["gameId"];

        notifyListeners();
        //
        break;
      case REQUEST_START:
        _waitingOpponent = false;
        handleRequestStart(message);
        break;
      case CHANGE_TURN:
        handleChangeTurn(message);
        break;
      case PLAYER_MOVE:
        handleOpponentPlayerMove(message);
        break;

      case FAILURE:
        handleDisconnect();
        errortoast("Communication Error");
      case OPPONENT_TIMEOUT:
        handleDisconnect();
        errortoast("Opponent Has Disconnected");

      case PLAYER_FORFEIT:
        handleDisconnect();
        errortoast("Opponent Has Forfeited");
      case REPLAY:
      default:
    }
  }

  void handleRequestStart(Map<String, dynamic> message) async {
    _isWhiteTurn = message["turn"] == PLAYER_ONE_TURN;

    _gameId = message["gameId"];

    _opponent = Player(
        name: message["opponentname"] ?? "UNKWON",
        userId: message["opponentId"],
        connectionId: message["opponentId"]);

    _localPlayer = _opponent = Player(
        name: message["opponentId"],
        userId: message["yourId"],
        connectionId: message["yourId"]);

    _isPlayer1 = message["isWhite"];

    await _initializeBoard(message["isWhite"]);

    _isLoading = false;

    _waitingOpponent = false;

    _isConnected = true;

    notifyListeners();
  }

  void handleChangeTurn(Map<String, dynamic> message) {
    if (message["turn"] == PLAYER_ONE_TURN) {
      _isWhiteTurn = true;
    } else if (message["turn"] == PLAYER_TWO_TURN) {
      _isWhiteTurn = false;
    }
    notifyListeners();
  }

  void handleOpponentPlayerMove(Map<String, dynamic> message) {
    bool isKing = message["isKing"];

    Map<String, dynamic> move = message['move'];

    Map<String, dynamic> source = move['source'];

    Map<String, dynamic> destination = move['destination'];

    bool hasCapture = message["captured"] == null ? false : true;

    int sourceRow = source['row'];

    int sourceCol = source['col'];

    int destRow = destination['row'];

    int destCol = destination['col'];

    // Get the moving piece from the source position
    CheckersPiece? movingPiece = _board[sourceRow][sourceCol];

    _board[sourceRow][sourceCol] = null;

    _board[destRow][destCol] = movingPiece;

    if (isKing) {
      _board[destRow][destCol]?.type = CheckersPieceType.king;
    }

    if (hasCapture) {
      var capturedItem = message["captured"];

      var capturedrow = capturedItem["row"];

      var capturedcol = capturedItem["col"];

      var isWhite = capturedItem["isWhite"];

      _board[capturedrow][capturedcol] = null;

      if (isWhite) {
        var piece =
            CheckersPiece(type: CheckersPieceType.normal, isWhite: isWhite);

        _whitePiecesCaptured.add(piece);
      } else if (!isWhite) {
        var piece =
            CheckersPiece(type: CheckersPieceType.normal, isWhite: isWhite);

        _blackPiecesCaptured.add(piece);
      }
    }
    notifyListeners();
  }

  void handleDisconnect() {
    _waitingOpponent = false;
    _isConnected = false;
    _isLoading = false;
    notifyListeners();
  }

  static const REQUEST_START = "START";
  static const PLAYER_MOVE = "MOVE";
  static const GAME_OVER = "GAMEOVER";
  static const PLAYER_ONE_TURN = "0";
  static const PLAYER_TWO_TURN = "1";
  static const PLAYER_WAIT = "WAIT_PLAYER2";
  static const CHANGE_TURN = "TURN";
  static const REPLAY = "REPLAY";
  static const FAILURE = "SYSTEM_FAILURE";
  static const OPPONENT_TIMEOUT = "TIMEOUT";
  static const PLAYER_FORFEIT = "FORFEIT";
}
