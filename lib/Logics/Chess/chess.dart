// ignore: file_names

bool isWhite(int index) {
  int x = index ~/ 8; //row
  int y = index % 8; // column

  return (x + y) % 2 == 0;
}
