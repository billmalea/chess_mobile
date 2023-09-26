import 'package:chekaz/Models/Piece.dart';

class Killed {
  late bool isKilled;
  Men? men;

  Killed({this.isKilled = false, this.men});

  Killed.none() {
    isKilled = false;
  }
}
