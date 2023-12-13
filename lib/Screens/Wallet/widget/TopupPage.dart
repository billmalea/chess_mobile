import 'dart:async';
import 'package:chekaz/Utility/Loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/Mpesa/MpesaProvider.dart';

class TopUpPage extends StatefulWidget {
  final String? phonenumber;

  const TopUpPage({super.key, required this.phonenumber});

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  bool _isLoading = false;

  bool _success = false;

  bool _failed = false;

  var amount;

  var phoneNumber;

  var paymentStatus;

  bool onPayNowSelected = true;

  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up'),
      ),
      body: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: LoadingPage(message: "Processing Payment"))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Radio<bool>(
                          activeColor: Colors.blue,
                          value: true,
                          groupValue: onPayNowSelected,
                          onChanged: (val) {
                            setState(() {
                              onPayNowSelected = val!;
                            });
                          },
                        ),
                        Image.asset(
                          'assets/images/mpesa.png',
                          width: 80,
                          height: 50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: TextFormField(
                        initialValue: widget.phonenumber,
                        style: const TextStyle(
                          height: 1.5,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 0.0,
                              color: Colors.black,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 0.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.0,
                            ),
                          ),
                          labelStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          labelText: "PhoneNumber",
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.black26,
                              width: 1.0,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a phone number';
                          }

                          final phoneRegex = RegExp(r'^[0-9]{10}$');

                          if (!phoneRegex.hasMatch(val)) {
                            return 'Please enter a valid phone number';
                          }

                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            phoneNumber = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: TextFormField(
                        style: const TextStyle(
                          height: 1.5,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 0.0,
                              color: Colors.black,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 0.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.0,
                            ),
                          ),
                          labelStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          labelText: "Amount",
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.black26,
                              width: 1.0,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please Enter Amount";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            amount = val;
                          });
                        },
                      ),
                    ),
                    InkWell(
                      onTap: _initiatePayment,
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
                            'Deposit',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }

  void _startCheckingPaymentStatus(String checkoutRequestID) {
    const Duration checkInterval = Duration(seconds: 3);

    // Start the cron job to check payment status every 1 second
    Timer.periodic(checkInterval, (Timer timer) async {
      // Check payment status
      var paymentStatus =
          await Provider.of<PaymentProvider>(context, listen: false)
              .checkPaymentStatus(checkoutRequestID);

      if (paymentStatus != null) {
        timer.cancel();
        setState(() {
          paymentStatus = paymentStatus;

          _isLoading = false;
        });
      } else {
        // Payment status retrieval failed
      }
    });
  }

  Future<void> _initiatePayment() async {
    var isValid = _key.currentState!.validate();

    if (isValid) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true;
      });

      final formattedPhoneNumber = '254${phoneNumber.substring(1)}';
      final String? checkoutRequestID =
          await Provider.of<PaymentProvider>(context, listen: false)
              .initiatePayment(formattedPhoneNumber, amount);

      if (checkoutRequestID != null) {
        print(
            'Payment initiated successfully. CheckoutRequestID: $checkoutRequestID');
        _startCheckingPaymentStatus(checkoutRequestID);
      } else {
        // Payment initiation failed, show an error message
        print('Payment initiation failed');
        // You may want to show an error message to the user

        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
