import 'package:flutter/material.dart';

class PokemonType extends StatelessWidget {
  final String _type1;
  final String _type2;
  PokemonType(this._type1, this._type2);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text("Types:", style: Theme.of(context).textTheme.bodySmall),
    ];

    if (_type1 != 'single_type') {
      children.add(Image.asset(
        'assets/type_icons/$_type1.png',
        width: 100,
      ));
    }
    if (_type2 != 'single_type') {
      children.add(Image.asset(
        'assets/type_icons/$_type2.png',
        width: 100,
      ));
    }

    return Wrap(
      children: children,
    );
  }
}
