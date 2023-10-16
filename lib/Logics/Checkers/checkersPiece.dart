enum CheckersPieceType { normal, king }

class CheckersPiece {
  CheckersPieceType type;
  final bool isWhite;

  CheckersPiece({required this.type, required this.isWhite});
}
