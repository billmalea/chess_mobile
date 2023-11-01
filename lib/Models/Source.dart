class Source {
  final int row;
  final int col;

  Source({required this.row, required this.col});
}

class Destination {
  final int row;
  final int col;

  Destination({required this.row, required this.col});
}

class Captured {
  final bool isWhite;
  final int row;
  final int col;

  Captured({required this.row, required this.col, required this.isWhite});
}
