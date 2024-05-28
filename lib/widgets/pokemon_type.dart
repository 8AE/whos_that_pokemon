import 'package:flutter/material.dart';

class PokemonType extends StatelessWidget {
  final String _type1;
  final String _type2;
  PokemonType(this._type1, this._type2);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Text("Types:"),
    ];

    if (_type1 != 'single_type') {
      children.add(Image.asset('assets/type_icons/$_type1.png'));
    }
    if (_type2 != 'single_type') {
      children.add(Image.asset('assets/type_icons/$_type2.png'));
    }

    return Row(
      children: children,
    );
  }
}
