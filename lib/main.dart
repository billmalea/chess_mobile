import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:chekaz/Providers/Mpesa/MpesaProvider.dart';
import 'package:chekaz/Providers/SignupPage/LoginNavigation.dart';
import 'package:chekaz/Providers/Websocket/WebsocketProvider.dart';
import 'package:chekaz/Screens/Home/Home.dart';
import 'package:chekaz/Screens/Profile/Profile.dart';
import 'package:chekaz/Screens/Referal/Referal.dart';
import 'package:chekaz/Screens/Wallet/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/Auth/CognitoAuthProvider.dart';
import 'Providers/NavProvider/BottomNavBar.dart';
import 'Screens/Tournament/Tournament.dart';
import 'Utility/endpoint/AmplifyConfigbuilder.dart';
import 'Utility/endpoint/endpoint.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future configureAmplify() async {
    if (Amplify.isConfigured) {
      return Future.value();
    }

    await Amplify.addPlugins([AmplifyAuthCognito()]);

    final stringConfiguration = AmplifyConfigurationBuilder.build(
      cognitoIdentityPoolId: cognitoUserpoolId,
      cognitoIdentityRegion: resourceRegion,
      cognitoUserPoolId: cognitoUserpoolId,
      cognitoUserPoolAppClientId: cognitoUserPoolClientId,
      cognitoUserPoolRegion: resourceRegion,
      authenticationFlowType: 'USER_SRP_AUTH',
      apiName: 'api',
      graphqlEndpoint: graphQlEndpoint,
      graphqlRegion: resourceRegion,
      graphqlapiKey: apiKeyGraphql,
    );
    try {
      await Amplify.configure(stringConfiguration);
    } catch (e) {
      print(e);
    }
  }

  await configureAmplify();

  runApp(
    MultiProvider(
      key: ObjectKey(DateTime.now().toString()),
      providers: [
        ChangeNotifierProvider(
          create: (context) => BottomNavProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WebSocketProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginNavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CognitoAuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<CognitoAuthProvider>(context, listen: false)
          .isLoggedIn(context);
      // ignore: use_build_context_synchronously
      await Provider.of<CognitoAuthProvider>(context, listen: false)
          .currentuser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chekaz',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(size: 17, color: Colors.white),
            color: Colors.black87,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.white)),
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.black87,
        useMaterial3: false,
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
