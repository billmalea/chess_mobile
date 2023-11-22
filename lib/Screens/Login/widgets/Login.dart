import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/Auth/CognitoAuthProvider.dart';
import '../../../Providers/SignupPage/LoginNavigation.dart';
import '../../../Utility/Formfield.dart';

class LoginWidget extends StatefulWidget {
  final dynamic route;
  const LoginWidget({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _loginFormKey = GlobalKey<FormState>();
  var _isloading = false;
  String _phoneNumberOrEmail = '';
  String _password = '';
  login() {
    var isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isloading = true;
      });

      final formattedPhoneNumber = '+254${_phoneNumberOrEmail.substring(1)}';

      Provider.of<CognitoAuthProvider>(context, listen: false)
          .signInUser(formattedPhoneNumber, _password, context, widget.route)
          .whenComplete(() {
        setState(() {
          _isloading = false;
        });
      });
    }
  }

  void signInWithGoogle() {
    print('Signing in with Google');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            const Text(
              'Login',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(
              height: 10,
            ),
            FormInputField(
              labelText: 'PhoneNumber',
              onchanged: (value) {
                setState(() {
                  _phoneNumberOrEmail = value!;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a phone number or email';
                }

                final emailRegex = RegExp(
                    r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                final phoneRegex = RegExp(r'^[0-9]{10}$');

                if (!emailRegex.hasMatch(value) &&
                    !phoneRegex.hasMatch(value)) {
                  return 'Please enter a valid email or a valid phone number';
                }

                return null;
              },
              ispassword: false,
            ),
            FormInputField(
              labelText: 'Password',
              onchanged: (value) {
                setState(() {
                  _password = value!;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
              ispassword: true,
            ),
            _isloading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  )
                : InkWell(
                    onTap: login,
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
            Container(
              margin: const EdgeInsets.only(
                  right: 25, left: 25, bottom: 10, top: 20),
              height: 40,
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t Have An Account ? ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<LoginNavigationProvider>(context,
                                listen: false)
                            .select(1);
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: signInWithGoogle,
              child: Container(
                margin: const EdgeInsets.only(
                    right: 25, left: 25, bottom: 10, top: 20),
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google icon
                    Image.asset(
                      'assets/images/google.png', // Replace with your Google icon asset
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 10),
                    // Text on the button
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
