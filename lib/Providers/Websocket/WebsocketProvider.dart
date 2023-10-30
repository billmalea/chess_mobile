import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../Logics/Checkers/checkersPiece.dart';
import '../../Models/Source.dart';

class WebSocketProvider with ChangeNotifier {
  void _initializeBoard(bool isWhite) {
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
    _board = newBoard;
  }

  List<List<CheckersPiece?>> _rotateBoard(
      List<List<CheckersPiece?>> originalBoard) {
    List<List<CheckersPiece?>> rotatedBoard = List.generate(
      8,
      (row) => List.generate(
        8,
        (col) {
          if ((row + col) % 2 == 1) {
            return originalBoard[7 - row][7 - col];
          }
          return null;
        },
      ),
    );
    return rotatedBoard;
  }

  List<List<CheckersPiece?>> get board => _board;
  List<List<CheckersPiece?>> _board = [];
  static const REQUEST_START = "START";
  static const PLAYER_MOVE = "MOVE"; //  player moves
  static const PLAYER_CAPTURE = "CAPTURE"; // New opcode for capturing pieces
  static const GAME_OVER_OP = "GAMEOVER"; // game over
  static const PLAYER_ONE_TURN = "0";
  static const PLAYER_TWO_TURN = "1";
  static const PLAYER_WAIT = "WAIT PLAYER2";
  static const CHANGE_TURN = "TURN";

  final serverUrl =
      "wss://wwpy70dc0e.execute-api.us-east-1.amazonaws.com/Prod/";
  String get playerId => _playerId;
  String get opponentId => _opponentId;
  String get gameId => _gameId;
  String _playerId = "";
  bool _isPlayer1 = false;
  String _gameId = "";
  String _opponentId = "";

  WebSocketChannel? _channel;

  bool _isConnected = false;

  bool get loading => _isLoading;

  bool get isWhiteTurn => _isWhiteTurn;

  bool get isPlayer1 => _isPlayer1;

  bool _isLoading = false;

  bool _isWhiteTurn = false;

  final StreamController<dynamic> _messageStreamController =
      StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageStreamController.stream;

  // Getter to check if the WebSocket is connected
  bool get isConnected => _isConnected;

  Future<void> websocketconnect() async {
    _channel = IOWebSocketChannel.connect(serverUrl);
  }

  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    _isLoading = true;

    await websocketconnect().then((value) {
      _isLoading = false;
    });

    _channel!.stream.listen(
      (message) {
        _isLoading = false;

        handleWebsocketmessage(message);
        _messageStreamController.add(message);
        notifyListeners();
      },
      onError: (e) {
        _isConnected = false;

        _isLoading = false;
        if (e is WebSocketChannelException) {}
      },
      onDone: () {},
      cancelOnError: true,
    );
  }

  // Send a message over the WebSocket
  void sendMessage(dynamic message) {
    if (_isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // Send a message over the WebSocket
  void sendMove(Source source, Destination destination) {
    final data = {
      "action": "notification",
      "operation": PLAYER_MOVE,
      "turn": isWhiteTurn ? PLAYER_ONE_TURN : PLAYER_TWO_TURN,
      "gameId": gameId,
      "move": {
        "source": {"row": source.row, "col": source.col},
        "destination": {"row": destination.row, "col": destination.col}
      }
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
    final data = {"action": "disconnect"};

    _channel!.sink.add(jsonEncode(data));
  }

  handleWebsocketmessage(dynamic data) {
    print("handling message $data");
    var message = jsonDecode(data);

    switch (message['operation']) {
      case REQUEST_START:
        // check if the player is player one
        _isWhiteTurn = message["turn"] == PLAYER_ONE_TURN ? true : false;

        _gameId = message["gameId"];

        print(_gameId);

        _opponentId = message["opponentId"];

        print(_opponentId);

        _playerId = message["yourId"];

        print(_playerId);

        _isPlayer1 = message["isWhite"];

        _initializeBoard(message["isWhite"]);

        _isConnected = true;
        print("-----------PLAYER 1----$_isPlayer1");

        notifyListeners();

        break;
      case CHANGE_TURN:
        if (message["turn"] == PLAYER_ONE_TURN) {
          //
          _isWhiteTurn = true;
          //
        } else if (message["turn"] == PLAYER_TWO_TURN) {
          //
          _isWhiteTurn = false;
          //
        }
        notifyListeners();
        break;
      default:
    }
  }
}
