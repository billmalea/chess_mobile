import 'package:chekaz/Models/Coordinate.dart';

class Men {
  late int player;
  late bool isKing;
  Coordinate? coordinate;

  Men({this.player = 1, this.isKing = false, this.coordinate});

  Men.of(Men men, {Coordinate? newCoor}) {
    player = men.player;
    isKing = men.isKing;
    coordinate = men.coordinate;

    if (newCoor != null) {
      coordinate = newCoor;
    }
  }

  upgradeToKing() {
    isKing = true;
  }
}
