import 'package:chekaz/Providers/Websocket/WebsocketProvider.dart';
import 'package:chekaz/Screens/Home/Home.dart';
import 'package:chekaz/Screens/Profile/Profile.dart';
import 'package:chekaz/Screens/Referal/Referal.dart';
import 'package:chekaz/Screens/Wallet/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/CheckersLogic/CheckersLogicProvider.dart';
import 'Providers/NavProvider/BottomNavBar.dart';
import 'Screens/Tournament/Tournament.dart';

void main() {
  runApp(
    MultiProvider(
      key: ObjectKey(DateTime.now().toString()),
      providers: [
        ChangeNotifierProvider(
          create: (context) => BottomNavProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CheckersGameProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WebSocketProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chekaz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> pages = [
    const Home(),
    const WalletPage(),
    const TournamentPage(),
    const ReferralPage(),
    ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    final selectedpage = Provider.of<BottomNavProvider>(context).selectetab;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 7,
            backgroundColor: Colors.grey.shade900,
            centerTitle: true,
            title: const Text(
              "Checkaz",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(child: pages.elementAt(selectedpage)),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 60,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              indicatorColor: Colors.grey.shade900,
            ),
            child: NavigationBar(
              selectedIndex: selectedpage,
              onDestinationSelected: (value) {
                Provider.of<BottomNavProvider>(context, listen: false)
                    .select(value);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_filled,
                  ),
                  label: 'Home',
                  selectedIcon: Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                  ),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                  ),
                  label: 'Wallet',
                  selectedIcon: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                  ),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.gamepad_outlined,
                  ),
                  label: 'Tournament',
                  selectedIcon: Icon(
                    Icons.games,
                    color: Colors.white,
                  ),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.link_outlined,
                  ),
                  label: 'Refferal',
                  selectedIcon: Icon(
                    Icons.link,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
