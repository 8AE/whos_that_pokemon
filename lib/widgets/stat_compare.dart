import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'dart:math';

class StatCompare extends StatelessWidget {
  final int stat1;
  final int stat2;
  final String statName;
  const StatCompare(this.stat1, this.stat2, this.statName, {super.key});

  String _symbolBasedOnStatDiff() {
    late String symbol;
    var diff = stat1 - stat2;
    if (diff == 0) {
      symbol = '=';
    } else if (diff > 0) {
      symbol = '↑';
    } else {
      symbol = '↓';
    }

    return symbol;
  }

  MaterialColor _colorsBasedOnStatDiff() {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 50,
      height: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(color: _colorsBasedOnStatDiff()),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Text("$statName ${_symbolBasedOnStatDiff()}"),
        ),
      ),
    );
  }
}
