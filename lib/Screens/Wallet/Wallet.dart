import 'package:chekaz/Screens/Wallet/widget/WithdrawPage.dart';
import 'package:chekaz/Utility/PageRoute.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/Auth/CognitoAuthProvider.dart';
import '../../main.dart';
import '../Login/SignupPage.dart';
import 'widget/TopupPage.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    var loggedIn = Provider.of<CognitoAuthProvider>(context).isSignedIn;
    return loggedIn
        ? const WalletUi()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Create an account or Login to Access Your Wallet.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignupPage(route: HomePage())),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      right: 25, left: 25, bottom: 10, top: 20),
                  height: 40,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Text("Or"),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignupPage(route: HomePage())),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      right: 25, left: 25, bottom: 10, top: 20),
                  height: 40,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

class WalletUi extends StatelessWidget {
  const WalletUi({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: Column(
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
                InkWell(
                  onTap: () {
                    pagenavigation(
                        context,
                        const TopUpPage(
                          phonenumber: null,
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 25, left: 25, bottom: 10, top: 20),
                    height: 40,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: const Center(
                      child: Text(
                        'Top Up',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    pagenavigation(
                        context,
                        const WithdrawPage(
                          phonenumber: null,
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 25, left: 25, bottom: 10, top: 20),
                    height: 40,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: const Center(
                      child: Text(
                        'Withdraw',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
            ),
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
