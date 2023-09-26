import 'package:chekaz/Models/Piece.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Logics/Checkers/Gametable.dart';
import 'Models/BlockTable.dart';
import 'Models/Coordinate.dart';
import 'Screens/Chess/ChessGameBoard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChessGameBoard(),
    );
  }
}

class MyGamePage extends StatefulWidget {
  final Color backgroundColor = const Color(0xffeec295);
  final Color foreGroundColor = const Color(0xff9a6851);
  final Color colorBorderTable = const Color(0xff6d3935);
  final Color colorAppBar = const Color(0xff6d3935);
  final Color colorBackgroundGame = const Color(0xffc16c34);
  final Color colorBackgroundHighlight = Colors.blue[500]!;
  final Color colorBackgroundHighlightAfterKilling = Colors.purple[500]!;

  MyGamePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyGamePageState createState() => _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {
  late GameTable gameTable;
  late int modeWalking;

  double blockSize = 1;

  @override
  void initState() {
    initGame();
    super.initState();
  }

  void initGame() {
    modeWalking = GameTable.MODE_WALK_NORMAL;
    gameTable = GameTable(countRow: 8, countCol: 8);
    gameTable.initMenOnTable();
  }

  @override
  Widget build(BuildContext context) {
    initScreenSize(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.colorAppBar,
          centerTitle: true,
          title: Text(widget.title.toUpperCase()),
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    initGame();
                  });
                })
          ],
        ),
        body: Container(
            color: widget.colorBackgroundGame,
            child: Column(children: <Widget>[
              Expanded(
                  child: Center(
                child: buildGameTable(),
              )),
              Container(
                decoration: BoxDecoration(
                    color: widget.colorAppBar,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 12)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[buildCurrentPlayerTurn()],
                ),
              ),
            ])));
  }

  void initScreenSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double shortestSide = MediaQuery.of(context).size.shortestSide;

    if (width < height) {
      blockSize = (shortestSide / 8) - (shortestSide * 0.03);
    } else {
      blockSize = (shortestSide / 8) - (shortestSide * 0.05);
    }
  }

  buildGameTable() {
    List<Widget> listCol = [];
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listRow = [];
      for (int col = 0; col < gameTable.countCol; col++) {
        listRow.add(buildBlockContainer(Coordinate(row: row, col: col)));
      }

      listCol.add(Row(mainAxisSize: MainAxisSize.min, children: listRow));
    }

    return Container(
        padding: const EdgeInsets.all(8),
        color: widget.colorBorderTable,
        child: Column(mainAxisSize: MainAxisSize.min, children: listCol));
  }

  Widget buildBlockContainer(Coordinate coor) {
    BlockTable block = gameTable.getBlockTable(coor);

    Color colorBackground;
    if (block.isHighlight) {
      colorBackground = widget.colorBackgroundHighlight;
    } else if (block.isHighlightAfterKilling) {
      colorBackground = widget.colorBackgroundHighlightAfterKilling;
    } else {
      if (gameTable.isBlockTypeF(coor)) {
        colorBackground = widget.backgroundColor;
      } else {
        colorBackground = widget.foreGroundColor;
      }
    }

    Widget menWidget;
    if (block.men != null) {
      Men? men = gameTable.getBlockTable(coor).men;

      menWidget = Center(
          child: buildMenWidget(
              player: men!.player, isKing: men.isKing, size: blockSize));

      if (men.player == gameTable.currentPlayerTurn) {
        menWidget = Draggable<Men>(
            feedback: menWidget,
            childWhenDragging: Container(),
            data: men,
            onDragStarted: () {
              setState(() {
                print("walking mode = ${modeWalking}");
                gameTable.highlightWalkable(men, mode: modeWalking);
              });
            },
            onDragEnd: (details) {
              setState(() {
                gameTable.clearHighlightWalkable();
              });
            },
            child: menWidget);
      }
    } else {
      menWidget = Container();
    }

    if (!gameTable.hasMen(coor) && !gameTable.isBlockTypeF(coor)) {
      return DragTarget<Men>(builder: (context, candidateData, rejectedData) {
        return buildBlockTableContainer(colorBackground, menWidget);
      }, onWillAccept: (men) {
        BlockTable blockTable = gameTable.getBlockTable(coor);
        return blockTable.isHighlight || blockTable.isHighlightAfterKilling;
      }, onAccept: (men) {
        print("onAccept");
        setState(() {
          gameTable.moveMen(men, Coordinate.of(coor));
          gameTable.checkKilled(coor);
          if (gameTable.checkKillableMore(men, coor)) {
            modeWalking = GameTable.MODE_WALK_AFTER_KILLING;
          } else {
            if (gameTable.isKingArea(
                player: gameTable.currentPlayerTurn, coor: coor)) {
              men.upgradeToKing();
            }
            modeWalking = GameTable.MODE_WALK_NORMAL;
            gameTable.clearHighlightWalkable();
            gameTable.togglePlayerTurn();
          }
        });
      });
    }

    return buildBlockTableContainer(colorBackground, menWidget);
  }

  Widget buildBlockTableContainer(Color colorBackground, Widget menWidget) {
    Widget containerBackground = Container(
        width: blockSize + (blockSize * 0.1),
        height: blockSize + (blockSize * 0.1),
        color: colorBackground,
        margin: const EdgeInsets.all(2),
        child: menWidget);
    return containerBackground;
  }

  Widget buildCurrentPlayerTurn() {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Current turn".toUpperCase(),
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              Padding(
                  padding: const EdgeInsets.all(6),
                  child: buildMenWidget(
                      player: gameTable.currentPlayerTurn, size: blockSize))
            ]));
  }

  buildMenWidget({int player = 1, bool isKing = false, double size = 32}) {
    if (isKing) {
      return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
              ],
              color: player == 1 ? Colors.black54 : Colors.grey[100]),
          child: Icon(Icons.star,
              color: player == 1
                  ? Colors.grey[100]!.withOpacity(0.5)
                  : Colors.black54.withOpacity(0.5),
              size: size - (size * 0.1)));
    }

    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
            ],
            color: player == 1 ? Colors.black54 : Colors.grey[100]));
  }
}
