import 'package:chekaz/Logics/Chess/chesspiece.dart';
import 'package:chekaz/Utility/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  const Square(
      {super.key,
      required this.isWhite,
      required this.onTap,
      required this.piece,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                fit: BoxFit.scaleDown,
              )
            : null,
      ),
    );
  }
}
