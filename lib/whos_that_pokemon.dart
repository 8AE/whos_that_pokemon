import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'dart:math';
import 'dart:convert';

class WhosThatPokemon extends StatefulWidget {
  const WhosThatPokemon({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<WhosThatPokemon> createState() => _WhosThatPokemonMainState();
}

class _WhosThatPokemonMainState extends State<WhosThatPokemon> {
  String _pokemonName = '';
  String _pokemonType1 = 'single_type';
  String _pokemonType2 = 'single_type';
  String _pokemonImageUrl = 'https://picsum.photos/250?image=9';

  Future<http.Response> _getRandomPokemonRaw() {
    var intValue = Random().nextInt(1200) + 1;

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<void> _generatePokemon() async {
    var data = await _getRandomPokemonRaw();
    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);

    setState(() {
      _pokemonName = randomPokemon.name;
      _pokemonType1 = randomPokemon.type1;
      _pokemonType2 = randomPokemon.type2;
      _pokemonImageUrl = randomPokemon.spriteImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Who's that pokemon?",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            _pokemonName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          PokemonType(_pokemonType1, _pokemonType2),
          Image.network(_pokemonImageUrl),
          TextButton(onPressed: _generatePokemon, child: const Text("Generate New Pokemon"))
        ],
      ),
    );
  }
}
