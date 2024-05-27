import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:who_that_pokemon/pokemon.dart';
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
  String _pokemonType1 = '';
  String _pokemonType2 = '';
  String _pokemonImageUrl = 'https://picsum.photos/250?image=9';

  Future<http.Response> _getRandomPokemonRaw() {
    var intValue = Random().nextInt(1200) + 1;

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<void> _incrementCounter() async {
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Who's that pokemon?",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              _pokemonName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _pokemonType1,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _pokemonType2,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Image.network(_pokemonImageUrl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
