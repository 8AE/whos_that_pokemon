import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'package:whos_that_pokemon/widgets/pokemon_guess.dart';
import 'dart:math';
import 'dart:convert';

class WhosThatPokemon extends StatefulWidget {
  late final Map<String, bool> generationMap;
  int correctGuessStreak;

  WhosThatPokemon(this.generationMap, this.correctGuessStreak, {super.key});

  @override
  State<WhosThatPokemon> createState() => _WhosThatPokemonMainState(generationMap);
}

class _WhosThatPokemonMainState extends State<WhosThatPokemon> {
  late final Map<String, bool> generationMap;
  late List<String> filteredGenList;

  int currentHp = 100;

  _WhosThatPokemonMainState(this.generationMap);

  @override
  void dispose() {
    // Dispose any controllers or focus nodes if you have any
    super.dispose();
  }

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
          title: Text('Congrats!!!', style: GoogleFonts.inter(color: Colors.green)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Yay good job you guessed it right.', style: GoogleFonts.inter(color: Colors.white)),
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
              child: Text('New Pokemon', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
                setState(() {
                  currentHp = 100;
                  widget.correctGuessStreak++;
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
          title: Text('Booo you suck!!!', style: GoogleFonts.inter(color: Colors.red)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Womp Womp you couldn't guess the pokemon", style: GoogleFonts.inter(color: Colors.white)),
                Text('it was ${pokemonToGuess!.name} btw', style: GoogleFonts.inter(color: Colors.white)),
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
              child: Text('New Pokemon', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
                setState(() {
                  currentHp = 100;
                  widget.correctGuessStreak = 0;
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

  Future<void> _streakBrokenDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('White Out', style: GoogleFonts.inter(color: Colors.red)),
          content: Text('Your Hp has reached 0 resulting in your correct guess streak to return to 0', style: GoogleFonts.inter(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Ok', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
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

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<Pokemon> _generatePokemon() async {
    var shuffleList = filteredGenList.toList()..shuffle();
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
    } else {
      setState(() {
        if (currentHp > 0) {
          currentHp -= 20;

          if (currentHp <= 0) {
            _streakBrokenDialog();
            widget.correctGuessStreak = 0;
          }
        } else {
          if (widget.correctGuessStreak > 0) {
            _streakBrokenDialog();
          }
          widget.correctGuessStreak = 0;
        }
      });
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

  _loading() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(
        color: Colors.purpleAccent,
      ),
    );
  }

  _pokemonData(Pokemon pkmData) {
    return [
      PokemonType(pkmData.type1, pkmData.type2),
      Text(
        'HP: ${pkmData.hp}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        'Attack: ${pkmData.attack}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        'Defense: ${pkmData.defense}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        'Special Attack: ${pkmData.specialAttack}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        'Special Defense: ${pkmData.specialDefense}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        'Speed: ${pkmData.speed}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  _guessingBox(List<String> pkmNameList) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return pkmNameList.where((String name) {
          return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: _guessPokemon,
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelStyle: GoogleFonts.inter(color: Colors.white),
            labelText: 'Search Pokémon',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.purpleAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.purpleAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.purpleAccent),
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
          ),
          onSubmitted: (value) {
            onFieldSubmitted();
            textEditingController.clear();
          },
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ListView(
              padding: const EdgeInsets.all(8.0),
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
    );
  }

  _giveupButton() {
    return SizedBox(
      width: 110,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purpleAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: () {
          _giveUp();
        },
        child: Text("Give Up", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _hpBar() {
    return Row(
      children: [
        Text(
          'HP: ',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: currentHp / 100,
            backgroundColor: Colors.grey,
            color: Colors.green,
            minHeight: 10,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$currentHp/100',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  _statBox() {
    return SizedBox(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purpleAccent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Stats",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: "Guessing Tier: "),
                      TextSpan(
                        text: "Pokeball",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Current Guesses: ${pkmnGuessed.length}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Correct Guess Streak: ${widget.correctGuessStreak.toString()}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: _hpBar(),
              ),
              const SizedBox(height: 5),
              _giveupButton(),
            ],
          ),
        ),
      ),
    );
  }

  _logo() {
    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 40,
            color: Colors.white,
          ),
          children: const [
            TextSpan(text: "Who's That "),
            TextSpan(
              text: "Pokémon",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }

  _desktopLayout() {
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
                    _logo(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenerationSelector(
                          generationMap: generationMap,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FutureBuilder<Pokemon>(
                                  future: _generatePokemon(),
                                  builder: (BuildContext context, AsyncSnapshot<Pokemon> snapshot) {
                                    List<Widget> children;
                                    if (snapshot.hasData) {
                                      children = _pokemonData(snapshot.data!);
                                    } else {
                                      children = [_loading()];
                                    }
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: children,
                                    );
                                  }),
                              Padding(padding: const EdgeInsets.all(8.0), child: _guessingBox(pkmNameList)),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: pkmnGuessed.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return PokemonGuess(pkmnGuessed[index], pokemonToGuess!);
                                },
                              )
                            ],
                          ),
                        ),
                        _statBox()
                      ],
                    ),
                  ],
                ),
              )
            ];
          } else {
            children = [_loading()];
          }
          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  _mobileLayout() {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            _statBox(),
            const SizedBox(height: 10),
            GenerationSelector(
              generationMap: generationMap,
            ),
          ],
        ),
      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        Flexible(child: _logo()),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder<Pokemon>(
                            future: _generatePokemon(),
                            builder: (BuildContext context, AsyncSnapshot<Pokemon> snapshot) {
                              List<Widget> children;
                              if (snapshot.hasData) {
                                children = [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Correct Guess Streak: ${widget.correctGuessStreak.toString()}",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.center,
                                    child: _hpBar(),
                                  ),
                                  const SizedBox(height: 10),
                                  ..._pokemonData(snapshot.data!)
                                ];
                              } else {
                                children = [_loading()];
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: children,
                              );
                            }),
                        Padding(padding: const EdgeInsets.all(8.0), child: _guessingBox(pkmNameList)),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: pkmnGuessed.length,
                          itemBuilder: (BuildContext context, int index) {
                            return PokemonGuess(pkmnGuessed[index], pokemonToGuess!);
                          },
                        )
                      ],
                    ),
                  ],
                ),
              )
            ];
          } else {
            children = [_loading()];
          }
          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    filteredGenList = generationMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _desktopLayout();
        } else {
          return _mobileLayout();
        }
      },
    );
  }
}
