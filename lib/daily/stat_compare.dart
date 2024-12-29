import 'package:flutter/material.dart';

class StatCompare {
  static MaterialColor colorsBasedOnStatDiff(int stat1, int stat2) {
    late MaterialColor color;
    var diff = (stat1 - stat2).abs();

    if (diff == 0) {
      color = Colors.green;
    } else if (diff > 30) {
      color = Colors.red;
    } else {
      color = Colors.amber;
    }

    return color;
  }

  static String symbolBasedOnStatDiff(int stat1, int stat2) {
    var diffColor = colorsBasedOnStatDiff(stat1, stat2);

    if (diffColor == Colors.green) {
      return '🟩';
    } else if (diffColor == Colors.red) {
      return '🟥';
    } else {
      return '🟨';
    }
  }
}
