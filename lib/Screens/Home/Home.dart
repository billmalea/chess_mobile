import 'package:chekaz/Screens/Checkers/CheckersStake/CheckersStake.dart';
import 'package:chekaz/Screens/Chess/ChessGameBoard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/Auth/CognitoAuthProvider.dart';
import 'widgets/GameOptionsDialog.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var isloading = false;

  @override
  Widget build(BuildContext context) {
    var autheniticated = Provider.of<CognitoAuthProvider>(context).isSignedIn;
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: <Widget>[
                GameItem(
                  title: 'Checkers',
                  onTap: () {
                    _showGameOptions(context, 'Checkers', autheniticated);
                  },
                ),
                GameItem(
                  title: 'Chess',
                  onTap: () {
                    _showGameOptions(context, 'Chess', autheniticated);
                  },
                ),
              ],
            ),
          ),
          isloading
              ? const SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                )
              : const SizedBox(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
            ),
            onPressed: () {
              setState(() {
                isloading = true;
              });
              Provider.of<CognitoAuthProvider>(context, listen: false)
                  .signOutGlobally()
                  .then((value) {
                setState(() {
                  isloading = false;
                });
              });
            },
            child: const Text('LogOut'),
          ),
        ],
      ),
    );
  }
}

void _showGameOptions(
    BuildContext context, String gameTitle, bool autheniticated) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
    ),
    builder: (BuildContext builder) {
      return GameOptionsDialog(
        gameTitle: gameTitle,
        autheniticated: autheniticated,
      );
    },
  );
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
