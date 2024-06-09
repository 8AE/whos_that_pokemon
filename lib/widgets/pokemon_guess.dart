import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';

class PokemonGuess extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonGuess(this.pokemon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Row(
        children: [
          Image.network(pokemon.spriteImageUrl),
          Text(
            pokemon.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
          PokemonType(pokemon.type1, pokemon.type2),
        ],
      ),
    );
  }
}
