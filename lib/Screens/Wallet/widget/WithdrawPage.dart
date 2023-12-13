import 'package:chekaz/Utility/Loading.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  final String? phonenumber;
  const WithdrawPage({super.key, required this.phonenumber});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  bool _isLoading = false;

  var amount;

  var phoneNumber;

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
      ),
      body: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(
                  child: LoadingPage(message: "Processing Withdrawal"))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'WITHDRAW TO MPESA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: _withdraw,
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
        ),
      ),
    );
  }

  void _withdraw() {
    var isValid = _key.currentState!.validate();
    if (isValid) {
      FocusScope.of(context).unfocus();

      final formattedPhoneNumber = '254${phoneNumber.substring(1)}';

      print('Withdraw initiated - Phone: $phoneNumber, Amount: $amount');
    }
  }
}
