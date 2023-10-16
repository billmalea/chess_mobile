import 'package:chekaz/Logics/Chess/chesspiece.dart';
import 'package:chekaz/Utility/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  const Square(
      {super.key,
      required this.isValidMove,
      required this.isWhite,
      required this.onTap,
      required this.piece,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null
            ? SizedBox(
                height: 25,
                width: 25,
                child: Image.asset(
                  piece!.imagePath,
                ),
              )
            : null,
      ),
    );
  }
}
