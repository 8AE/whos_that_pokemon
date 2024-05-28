import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'dart:math';
import 'dart:convert';

class WhosThatPokemon extends StatefulWidget {
  const WhosThatPokemon({super.key});

  @override
  State<WhosThatPokemon> createState() => _WhosThatPokemonMainState();
}

class _WhosThatPokemonMainState extends State<WhosThatPokemon> {
  Future<http.Response> _getRandomPokemonRaw() {
    var intValue = Random().nextInt(150) + 1; // only OG for now

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<Pokemon> _generatePokemon() async {
    var data = await _getRandomPokemonRaw();
    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);

    return randomPokemon;
  }

  Future<void> _refreshPokemon() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<Pokemon>(
            future: _generatePokemon(),
            builder: (BuildContext context, AsyncSnapshot<Pokemon> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = [
                  Text(
                    "Who's that pokemon?",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    snapshot.data!.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  PokemonType(snapshot.data!.type1, snapshot.data!.type2),
                  Image.network(snapshot.data!.spriteImageUrl),
                  TextButton(onPressed: _refreshPokemon, child: const Text("Generate New Pokemon"))
                ];
              } else {
                children = [const CircularProgressIndicator()];
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: children,
              );
            }));
  }
}
