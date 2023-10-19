import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 80,
          ),
          SizedBox(height: 20),
          Text(
            'Username: JohnDoe',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Email: john@example.com',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Wins: 10',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Losses: 5',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Draws: 2',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
