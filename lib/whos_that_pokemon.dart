import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'package:whos_that_pokemon/widgets/pokemon_guess.dart';
import 'dart:math';
import 'dart:convert';

class WhosThatPokemon extends StatefulWidget {
  late final Map<String, bool> generationMap;
  WhosThatPokemon(this.generationMap, {super.key});

  @override
  State<WhosThatPokemon> createState() => _WhosThatPokemonMainState(generationMap);
}

class _WhosThatPokemonMainState extends State<WhosThatPokemon> {
  late final Map<String, bool> generationMap;
  late List<String> filteredGenList;

  _WhosThatPokemonMainState(this.generationMap);

  final List<Pokemon> pkmnGuessed = [];
  Pokemon? pokemonToGuess;

  Map<String, int> generationLower = {
    "gen1": 1,
    "gen2": 151,
    "gen3": 251,
    "gen4": 386,
    "gen5": 493,
    "gen6": 649,
    "gen7": 721,
    "gen8": 809,
    "gen9": 905,
  };

  Map<String, int> generationUpper = {
    "gen1": 151,
    "gen2": 251,
    "gen3": 386,
    "gen4": 493,
    "gen5": 649,
    "gen6": 721,
    "gen7": 809,
    "gen8": 905,
    "gen9": 1025,
  };

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congrats!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Yay good job you guessed it right.'),
                Image.network(
                  pokemonToGuess!.spriteImageUrl,
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('New Pokemon'),
              onPressed: () {
                setState(() {
                  pkmnGuessed.clear();
                  pokemonToGuess = null;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _giveUp() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booo you suck!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text("Womp Womp you couldn't guess the pokemon"),
                Text('it was ${pokemonToGuess!.name} btw'),
                Image.network(
                  pokemonToGuess!.spriteImageUrl,
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('New Pokemon'),
              onPressed: () {
                setState(() {
                  pkmnGuessed.clear();
                  pokemonToGuess = null;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<http.Response> _getRandomPokemonRawFromGeneration(String generation) {
    var intValue = generationLower[generation]! + Random().nextInt((generationUpper[generation]! + 1) - generationLower[generation]!);

    print(intValue);

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<Pokemon> _generatePokemon() async {
    var shuffleList = filteredGenList.toList()..shuffle();
    print(shuffleList);
    var data = await _getRandomPokemonRawFromGeneration(shuffleList.first);
    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);
    pokemonToGuess ??= randomPokemon;

    return pokemonToGuess!;
  }

  Future<void> _guessPokemon(String name) async {
    final httpResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
    pkmnGuessed.add(Pokemon.fromHttpBody(httpResponse.body));

    if (name.toLowerCase() == pokemonToGuess!.name.toLowerCase()) {
      _showMyDialog();
    }

    setState(() {});
  }

  Future<List<String>> _generatePokemonListWithGen(String generation) async {
    var pokemonListRaw = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=${generationUpper[generation]! - generationLower[generation]!}&offset=${generationLower[generation]}'));
    var jsonData = jsonDecode(pokemonListRaw.body);
    List<String> pkmnList = [];

    for (var pokemonEntry in jsonData['results']) {
      pkmnList.add(pokemonEntry['name']);
    }

    return pkmnList;
  }

  Future<List<String>> _generatePokemonList() async {
    List<String> pkmnList = [];
    for (var generation in filteredGenList) {
      pkmnList.addAll(await _generatePokemonListWithGen(generation));
    }

    return pkmnList;
  }

  @override
  Widget build(BuildContext context) {
    filteredGenList = generationMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    return Scaffold(
        body: FutureBuilder<List<String>>(
            future: _generatePokemonList(),
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                List<String> pkmNameList = snapshot.data!;
                children = [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        FutureBuilder<Pokemon>(
                            future: _generatePokemon(),
                            builder: (BuildContext context, AsyncSnapshot<Pokemon> snapshot) {
                              List<Widget> children;
                              if (snapshot.hasData) {
                                children = [
                                  Text(
                                    "Who's that pokemon?",
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  ElevatedButton(onPressed: _giveUp, child: const Text('Give up :(')),
                                  PokemonType(snapshot.data!.type1, snapshot.data!.type2),
                                  Text(
                                    'HP: ${snapshot.data!.hp}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Attack: ${snapshot.data!.attack}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Defense: ${snapshot.data!.defense}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Special Attack: ${snapshot.data!.specialAttack}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Special Defense: ${snapshot.data!.specialDefense}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Speed: ${snapshot.data!.speed}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ];
                              } else {
                                children = [const CircularProgressIndicator()];
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: children,
                              );
                            }),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return pkmNameList.where((String name) {
                              return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: _guessPokemon,
                          fieldViewBuilder:
                              (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: Icon(Icons.search),
                              ),
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ListView(
                                  padding: EdgeInsets.all(8.0),
                                  children: options.map((String option) {
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: pkmnGuessed.length,
                          itemBuilder: (BuildContext context, int index) {
                            return PokemonGuess(pkmnGuessed[index], pokemonToGuess!);
                          },
                        )
                      ],
                    ),
                  )
                ];
              } else {
                children = [const CircularProgressIndicator()];
              }
              return ListView(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: children,
              );
            }));
  }
}
