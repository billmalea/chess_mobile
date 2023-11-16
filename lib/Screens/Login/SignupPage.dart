import 'package:chekaz/Screens/Login/widgets/Login.dart';
import 'package:chekaz/Screens/Login/widgets/Signup.dart';
import 'package:chekaz/Screens/Login/widgets/Verify.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/SignupPage/LoginNavigation.dart';

class SignupPage extends StatefulWidget {
  final dynamic route;

  const SignupPage({Key? key, required this.route}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final selectedPage =
        Provider.of<LoginNavigationProvider>(context).selectedpage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: _getPageWidget(
            selectedPage,
          ),
        ),
      ),
    );
  }

  Widget _getPageWidget(
    int selectedPage,
  ) {
    switch (selectedPage) {
      case 0:
        return LoginWidget(
          route: widget.route,
        );
      case 1:
        return const RegisterWidget();
      case 2:
        return VerificationWidget(
          route: widget.route,
        );
      default:
        return Container();
    }
  }
}
