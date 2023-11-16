import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Utility/Formfield.dart';

class VerificationWidget extends StatefulWidget {
  final dynamic route;
  const VerificationWidget({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  State<VerificationWidget> createState() => _VerificationWidgetState();
}

class _VerificationWidgetState extends State<VerificationWidget> {
  final _loginFormKey = GlobalKey<FormState>();
  var _isloading = false;

  String _verificationcode = '';

  verify() {
    var isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isloading = true;
      });

      // Provider.of<CognitoAuthProvider>(context, listen: false)
      //     .confirmUser(
      //         confirmationCode: _verificationcode,
      //         context: context,
      //         route: widget.route)
      //     .whenComplete(() {
      //   setState(() {
      //     _isloading = false;
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    // var email = Provider.of<CognitoAuthProvider>(context, listen: false)
    //     .verificationEmail;
    var email = "";

    var registeredEmail = email.isEmpty ? 'your email Address' : email;
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
              'Verify Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(
              height: 10,
            ),
            FormInputField(
              labelText: 'Enter verification code',
              onchanged: (value) {
                setState(() {
                  _verificationcode = value!;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a Verification code sent to $email';
                }
                return null;
              },
              ispassword: false,
            ),
            _isloading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  )
                : InkWell(
                    onTap: verify,
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 25, left: 25, bottom: 10, top: 20),
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7)),
                      ),
                      child: const Center(
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'A verification code has been sent to $registeredEmail ',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
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
                      'Didn\'t Receive Code ? ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
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
