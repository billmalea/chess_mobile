import 'package:chekaz/Logics/Checkers/checkersPiece.dart';
import 'package:chekaz/Logics/Chess/chesspiece.dart';
import 'package:chekaz/Utility/colors.dart';
import 'package:flutter/material.dart';

class CheckerSquare extends StatelessWidget {
  final bool isWhite;
  final CheckersPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  const CheckerSquare(
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
      squareColor = const Color.fromARGB(255, 74, 179, 78);
    } else if (isValidMove) {
      squareColor = const Color.fromARGB(255, 23, 221, 33);
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
                child: buildPieceWidget(iswhite: isWhite, type: piece!.type),
              )
            : null,
      ),
    );
  }

  buildPieceWidget({
    required bool iswhite,
    required CheckersPieceType type,
  }) {
    if (type == CheckersPieceType.king) {
      return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
              ],
              color: !piece!.isWhite ? Colors.black54 : Colors.grey[100]),
          child: Icon(Icons.star,
              color: !piece!.isWhite
                  ? Colors.grey[100]!.withOpacity(0.5)
                  : Colors.black54.withOpacity(0.5),
              size: 32 - (32 * 0.1)));
    }

    return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
            ],
            color: !piece!.isWhite ? Colors.orange : Colors.grey[100]));
  }
}
