import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ksh 500.00',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                  onPressed: () {
                    // Implement the logic for account top-up
                  },
                  child: const Text('Top Up'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                  onPressed: () {
                    // Implement the logic for account withdrawal
                  },
                  child: const Text('Withdraw'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
            ),
            // You can create a list view of recent transactions here
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.only(top: 0),
                    subtitleTextStyle:
                        TextStyle(fontSize: 12, color: Colors.black),
                    subtitle: Text('18-10-2023'),
                    trailing: Text('+500'),
                    titleTextStyle:
                        TextStyle(fontSize: 13, color: Colors.black),
                    leading: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green,
                    ),
                    title: Text('Top up  Ksh 500'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(top: 0),
                    subtitleTextStyle:
                        TextStyle(fontSize: 12, color: Colors.black),
                    subtitle: Text('18-10-2023'),
                    trailing: Text('+500'),
                    titleTextStyle:
                        TextStyle(fontSize: 13, color: Colors.black),
                    leading: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green,
                    ),
                    title: Text('Won  Ksh 500'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
