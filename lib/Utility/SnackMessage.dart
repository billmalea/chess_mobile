import 'package:flutter/material.dart';

snackmessage(String message, BuildContext ctx) {
  return ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(duration: const Duration(minutes: 1), content: Text(message)),
  );
}
