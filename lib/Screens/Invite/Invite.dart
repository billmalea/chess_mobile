import 'package:flutter/material.dart';

class InvitePage extends StatelessWidget {
  void generateAndShareLink() {
    // Generate the link for inviting friends
    String inviteLink = 'https://yourapp.com/invite';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite A Friend'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Share this link with your friends:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateAndShareLink,
              child: const Text('Generate & Share Link'),
            ),
          ],
        ),
      ),
    );
  }
}
