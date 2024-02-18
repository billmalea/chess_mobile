import 'package:flutter/material.dart';

pagenavigation(BuildContext ctx, dynamic route) {
  Navigator.push(ctx, MaterialPageRoute(builder: (_) => route));
}

pagenavigationreplace(BuildContext ctx, dynamic route) {
  Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => route));
}
