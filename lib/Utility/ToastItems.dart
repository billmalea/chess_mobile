import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

successtoast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

errortoast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

String currencyformat(int currency) {
  final formatCurrency = NumberFormat.simpleCurrency(
      locale: Platform.localeName, name: 'Ksh ', decimalDigits: 0);

  var formated = formatCurrency.format(currency);
  return formated;
}

String currency(int currency) {
  final formatCurrency = NumberFormat.simpleCurrency(
      locale: Platform.localeName, name: 'Ksh ', decimalDigits: 0);

  var formated = formatCurrency.format(currency);
  return formated;
}

String formatDate(String inputDate) {
  DateTime dateTime = DateTime.parse(inputDate);

  final formatter = DateFormat('dd-MM-yyyy');

  // Format the DateTime object to the desired format
  return formatter.format(dateTime);
}
