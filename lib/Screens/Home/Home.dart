import 'package:chekaz/Screens/Checkers/CheckersGameBoard.dart';
import 'package:chekaz/Screens/Chess/ChessGameBoard.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: <Widget>[
          GameItem(
            title: 'Checkers',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CheckersBoardGame()));
            },
          ),
          GameItem(
            title: 'Chess',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChessGameBoard()));
            },
          ),
        ],
      ),
    );
  }
}

class GameItem extends StatelessWidget {
  final String title;
  final Function onTap;

  const GameItem({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.gamepad, size: 60),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
            onPressed: () {
              onTap();
            },
            child: const Text('Play '),
          ),
        ],
      ),
    );
  }
}
