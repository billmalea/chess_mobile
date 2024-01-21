import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:chekaz/Utility/ToastItems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utility/PageRoute.dart';
import '../SignupPage/LoginNavigation.dart';

class CognitoAuthProvider extends ChangeNotifier {
  bool get isSignedIn => _isSignedIn;
  bool _isSignedIn = false;
  String _confirmUsername = '';
  String _confirmpassword = '';
  String _verificationemail = '';
  String get verificationEmail => _verificationemail;

  AuthUser? _user;

  isLoggedIn(BuildContext context) async {
    final AuthSession res = await Amplify.Auth.fetchAuthSession();

    _isSignedIn = res.isSignedIn;
    notifyListeners();
  }

  AuthUser? get user => _user;

  currentuser(BuildContext ctx) async {
    try {
      AuthUser currentUser = await Amplify.Auth.getCurrentUser();

      _user = currentUser;

      notifyListeners();
    } on SignedOutException {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Connection timed out.Please Try again.')),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> autologin(String username, String password) async {
    final result = await Amplify.Auth.signIn(
      username: username,
      password: password,
    );
    return result.isSignedIn;
  }

  Future<SignInResult?> signInUser(
      String username, String password, BuildContext cxt, dynamic route) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );

      _confirmUsername = username;

      _confirmpassword = password;
      notifyListeners();

      // ignore: use_build_context_synchronously
      await _handleSignInResult(result, cxt, route, username, password, false);

      return result;
    } on SocketException {
      safePrint('Error signing up user: NOT INTERNET CONNECTION');
    } on UsernameExistsException {
      safePrint('Error signing up user: USERNAME EXISTS');
    } on AuthException catch (e) {
      safePrint('Error signing up user: ${e.message}');
    }

    return null;
  }

  Future<void> signUpUser(
      {required String username,
      required String password,
      required String email,
      required String phoneNumber,
      required BuildContext context,
      dynamic route}) async {
    try {
      var key = const CognitoUserAttributeKey.custom('custom:usergroup');
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.phoneNumber: phoneNumber,
        AuthUserAttributeKey.name: username,
        key: 'users'
      };

      _confirmUsername = phoneNumber;
      _confirmpassword = password;
      _verificationemail = email;
      notifyListeners();
      final result = await Amplify.Auth.signUp(
        username: phoneNumber,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes.cast<AuthUserAttributeKey, String>(),
        ),
      );
      // ignore: use_build_context_synchronously
      await _handleSignUpResult(
          result, context, route, phoneNumber, password, false);
    } on SocketException {
      safePrint('Error signing up user: NOT INTERNET CONNECTION');
    } on UsernameExistsException {
      safePrint('Error signing up user: USERNAME EXISTS');
    } on AuthException catch (e) {
      errortoast(e.message);
      safePrint('Error signing up user**************: ${e.message}');
    }
  }

  Future<void> confirmUser(
      {required String confirmationCode,
      required BuildContext context,
      required dynamic route}) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: _confirmUsername,
        confirmationCode: confirmationCode,
      );

      // ignore: use_build_context_synchronously
      _handleSignUpResult(
          result, context, route, _confirmUsername, _confirmpassword, true);
    } on AuthException catch (e) {
      safePrint('Error confirming user: ${e.message}');
    }
  }

  Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  Future<void> signInWithGoogle() async {
    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );
      safePrint('Sign in result: $result');
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> _handleSignInResult(SignInResult result, BuildContext context,
      dynamic route, String username, String password, bool confirmuser) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignInStep.confirmSignInWithNewPassword:
        safePrint('Enter a new password to continue signing in');
        break;
      case AuthSignInStep.continueSignInWithMfaSelection:
        break;
      case AuthSignInStep.continueSignInWithTotpSetup:
        break;
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        break;
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        final parameters = result.nextStep.additionalInfo;
        final prompt = parameters['prompt']!;
        safePrint(prompt);
        break;
      case AuthSignInStep.resetPassword:
        final resetResult = await Amplify.Auth.resetPassword(
          username: 'username',
        );

        await _handleResetPasswordResult(resetResult);

        break;

      case AuthSignInStep.confirmSignUp:
        // Resend the sign up code to the registered device.
        final resendResult = await Amplify.Auth.resendSignUpCode(
          username: username,
        );

        _handleCodeDelivery(resendResult.codeDeliveryDetails);

        // ignore: use_build_context_synchronously
        Provider.of<LoginNavigationProvider>(context, listen: false).select(2);

        break;
      case AuthSignInStep.done:
        await currentuser(context);
        // ignore: use_build_context_synchronously
        pagenavigationreplace(context, route);
        break;
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result, BuildContext context,
      dynamic route, String username, String password, bool confirmuser) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);

        Provider.of<LoginNavigationProvider>(context, listen: false).select(2);

        break;
      case AuthSignUpStep.done:
        if (confirmuser) {
          await autologin(username, password);
        }

        // ignore: use_build_context_synchronously

        // ignore: use_build_context_synchronously
        pagenavigationreplace(context, route);
        break;
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
  }

  Future<void> _handleResetPasswordResult(ResetPasswordResult result) async {
    safePrint(
        'A confirmation code has been sent to ${result.isPasswordReset}. ');
  }

  ///////////////////////////
  Future<bool> signOutGlobally() async {
    final result = await Amplify.Auth.signOut(
      options: const SignOutOptions(globalSignOut: true),
    );
    if (result is CognitoCompleteSignOut) {
      _user = null;

      notifyListeners();
      safePrint('Sign out completed successfully');
      return true;
    } else if (result is CognitoPartialSignOut) {
      final globalSignOutException = result.globalSignOutException!;

      safePrint('Error signing user out: ${globalSignOutException.message}');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
      return false;
    }
    return false;
  }

  clearUserdata() {
    notifyListeners();
  }
}
