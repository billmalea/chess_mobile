import 'package:flutter/material.dart';

import 'Models/Checkers.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CheckersLogic logic = CheckersLogic();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: CheckersBoard([
          [0, 1, 0, 1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1, 0, 1, 0],
          [0, 1, 0, 1, 0, 1, 0, 1],
          [0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0],
          [2, 0, 2, 0, 2, 0, 2, 0],
          [0, 2, 0, 2, 0, 2, 0, 2],
          [2, 0, 2, 0, 2, 0, 2, 0],
        ]),
      ),
    );
  }
}

class CheckersBoard extends StatelessWidget {
  final List<List<int>> boardState;

  const CheckersBoard(this.boardState, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 64,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final isDarkSquare = (row + col) % 2 == 1;
        final piece = boardState[row][col];

        return Container(
          color: isDarkSquare ? Colors.brown : Colors.white,
          child: piece == 1
              ? _buildCheckerPiece(Colors.red)
              : piece == 2
                  ? _buildCheckerPiece(Colors.black)
                  : null,
        );
      },
    );
  }

  Widget _buildCheckerPiece(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
