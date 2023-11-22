import 'package:chekaz/Providers/Auth/CognitoAuthProvider.dart';
import 'package:chekaz/Screens/Checkers/CheckersFriendly/CheckersFriendly.dart';
import 'package:chekaz/Screens/Checkers/CheckersStake/CheckersStake.dart';
import 'package:chekaz/Screens/Checkers/Offline/CheckersGameOffline.dart';
import 'package:chekaz/Screens/Home/Home.dart';
import 'package:chekaz/Screens/Login/SignupPage.dart';
import 'package:chekaz/Utility/PageRoute.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameOptionsDialog extends StatelessWidget {
  final String gameTitle;
  final bool autheniticated;
  const GameOptionsDialog({
    Key? key,
    required this.autheniticated,
    required this.gameTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/kemoney.webp"),
            radius: 20,
          ),
          // ignore: unnecessary_const
          title: const Text(
            'Stake Based Online Multiplayer',
            //
            style: TextStyle(fontSize: 13),
          ),
          onTap: () {
            autheniticated == true
                ? pagenavigation(context, const CheckersStake())
                : pagenavigation(
                    context,
                    const SignupPage(
                      route: CheckersStake(),
                    ));
          },
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/battle.png"),
            radius: 20,
          ),
          title: const Text(
            'Online Multiplayer Friendly',
            style: TextStyle(fontSize: 13),
          ),
          onTap: () {
            autheniticated == true
                ? pagenavigation(context, const CheckersStake())
                : pagenavigation(
                    context,
                    const SignupPage(
                      route: CheckersFriendlyOnline(),
                    ));
          },
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/bot.png"),
            radius: 20,
          ),
          title: const Text(
            'Local Vs Computer',
            style: TextStyle(fontSize: 13),
          ),
          onTap: () {
            pagenavigation(context, const CheckersStake());
          },
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/team.png"),
            radius: 20,
          ),
          title: const Text(
            'Local Multiplayer',
            style: TextStyle(fontSize: 13),
          ),
          onTap: () {
            pagenavigation(context, const CheckersOfflineMultiplayer());
          },
        ),
      ],
    );
  }
}
