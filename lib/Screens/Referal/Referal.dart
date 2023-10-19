import 'package:flutter/material.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Refer friends and earn cash!'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Implement referral logic here
            // Generate a unique referral link or code
          },
          child: const Text('Get Referral Link'),
        ),
      ],
    ));
  }
}
