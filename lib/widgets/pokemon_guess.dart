import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'package:whos_that_pokemon/widgets/stat_compare.dart';

class PokemonGuess extends StatelessWidget {
  final Pokemon pokemon;
  final Pokemon answer;
  const PokemonGuess(this.pokemon, this.answer, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: Center(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Image.network(
              pokemon.spriteImageUrl,
              height: 100,
            ),
            Text(
              pokemon.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
            PokemonType(pokemon.type1, pokemon.type2),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.hp, answer.hp, 'hp'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.attack, answer.attack, 'attack'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.defense, answer.defense, 'defense'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.specialAttack, answer.specialAttack, 'sp attack'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.specialDefense, answer.specialDefense, 'sp defense'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: StatCompare(pokemon.speed, answer.speed, 'speed'),
            ),
          ],
        ),
      ),
    );
  }
}
