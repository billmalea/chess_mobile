import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Utility/endpoint/endpoint.dart';

class PaymentProvider extends ChangeNotifier {
  String? _token;

  String generateTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMddHHmmss');
    return formatter.format(now);
  }

  String generatePassword(
      String businessShortCode, String passKey, String timestamp) {
    final stringToEncode = '$businessShortCode$passKey$timestamp';
    final bytes = utf8.encode(stringToEncode);
    final password = base64.encode(bytes);
    return password;
  }

  Future<String?> initiatePayment(String phoneNumber, dynamic amount) async {
    final timeStamp = generateTimestamp();
    final password = generatePassword(shortCode, mpesaPassKey, timeStamp);
    final token = await _getAccessToken();
    _token = token;
    notifyListeners();

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final payload = {
      'BusinessShortCode': shortCode,
      'Password': password,
      'Timestamp': timeStamp,
      'TransactionType': 'CustomerBuyGoodsOnline',
      'Amount': amount,
      'PartyA': phoneNumber,
      'PartyB': tillNumber,
      'PhoneNumber': phoneNumber,
      'CallBackURL': callbackApiUrl,
      'AccountReference': 'Payments',
      'TransactionDesc': 'Ramii customers payment mobile',
    };

    try {
      final response = await http.post(
        Uri.parse(initatePaymentUrl),
        headers: headers,
        body: json.encode(payload),
      );

      final responseData = json.decode(response.body);
      final checkoutRequestID = responseData['CheckoutRequestID'];

      return checkoutRequestID;
    } on SocketException {
      //errortoast('Check Your Internet Connection and Try Again');
      return null;
    } catch (e) {
      //errortoast(e.toString());
      print('++++++initiate pay error++++++ $e');
      return null;
    }
  }

  Future<dynamic> checkPaymentStatus(String checkoutRequestID) async {
    final timeStamp = generateTimestamp();
    final password = generatePassword(shortCode, mpesaPassKey, timeStamp);

    final headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };

    final payload = {
      'BusinessShortCode': shortCode,
      'Password': password,
      'Timestamp': timeStamp,
      'CheckoutRequestID': checkoutRequestID,
    };
    try {
      final response = await http.post(
        Uri.parse(checkPaymentUrl),
        headers: headers,
        body: json.encode(payload),
      );

      final responseData = json.decode(response.body);
      final responsecode = responseData['errorCode'].toString();

      if (responsecode == '500.001.1001') {
        return null;
      }
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final headers = {
        'Authorization':
            'Basic ${base64.encode(utf8.encode('$mpesaClientKey:$mpesaClientSecret'))}',
      };
      final response =
          await http.get(Uri.parse(accessTokenurl), headers: headers);
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];

      return accessToken;
    } on SocketException {
      // errortoast('Check Your Internet Connection and Try Again');
      return null;
    } catch (e) {
      return null;
    }
  }
}
