import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final String message;
  const LoadingPage({super.key, required this.message});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .2,
        ),
        SizedBox(
            height: 100,
            width: 100,
            child: Image.asset("assets/images/loader.gif")),
        const SizedBox(
          height: 10,
        ),
        Text(widget.message)
      ],
    );
  }
}
