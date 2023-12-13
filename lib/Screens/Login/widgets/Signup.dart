import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/Auth/CognitoAuthProvider.dart';
import '../../../Providers/SignupPage/LoginNavigation.dart';
import '../../../Utility/Formfield.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({Key? key}) : super(key: key);

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _registerFormKey = GlobalKey<FormState>();
  String _username = '';

  String _phoneNumber = '';

  String _email = '';

  String _password = '';

  String _confirmPassword = '';

  var _isloading = false;

  register() {
    var isValid = _registerFormKey.currentState!.validate();
    if (isValid) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isloading = true;
      });
      final formattedPhoneNumber = '+254${_phoneNumber.substring(1)}';

      Provider.of<CognitoAuthProvider>(context, listen: false)
          .signUpUser(
        username: _username,
        password: _password,
        email: _email,
        phoneNumber: formattedPhoneNumber,
        context: context,
      )
          .whenComplete(() {
        setState(() {
          _isloading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
          ),
          const SizedBox(
            height: 10,
          ),
          FormInputField(
            labelText: 'Username',
            onchanged: (value) {
              setState(() {
                _username = value!;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
            ispassword: false,
          ),
          FormInputField(
            labelText: 'PhoneNumber',
            onchanged: (value) {
              setState(() {
                _phoneNumber = value!;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a phone number';
              }

              final phoneRegex = RegExp(r'^[0-9]{10}$');

              if (!phoneRegex.hasMatch(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            ispassword: false,
          ),
          FormInputField(
            labelText: 'Email',
            onchanged: (value) {
              setState(() {
                _email = value!;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter an email Address';
              }

              final emailRegex = RegExp(
                  r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');

              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
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
          FormInputField(
            labelText: 'Confirm Password',
            onchanged: (value) {
              setState(() {
                _confirmPassword = value!;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _password) {
                return 'Passwords do not match';
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
                  onTap: register,
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
          Container(
            margin:
                const EdgeInsets.only(right: 25, left: 25, bottom: 10, top: 20),
            height: 40,
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already Have An Account ? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Provider.of<LoginNavigationProvider>(context,
                              listen: false)
                          .select(0);
                    },
                    child: const Text(
                      'Login ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
