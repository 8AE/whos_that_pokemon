import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/items/generation_detector.dart';
import 'package:whos_that_pokemon/items/pokedex_scope.dart';
import 'package:whos_that_pokemon/items/potion.dart';
import 'package:whos_that_pokemon/items/super_potion.dart';
import 'package:whos_that_pokemon/items/usable_item.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon_species.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'dart:math';
import 'dart:convert';
import 'package:sembast/sembast.dart';

// ignore: must_be_immutable
class WhosThatPokemon extends StatefulWidget {
  final Database db;
  late final Map<String, bool> generationMap;
  int correctGuessStreak;

  WhosThatPokemon(this.generationMap, this.correctGuessStreak, this.db, {super.key});

  @override
  State<WhosThatPokemon> createState() => _WhosThatPokemonMainState(generationMap);
}

class _WhosThatPokemonMainState extends State<WhosThatPokemon> {
  late final Map<String, bool> generationMap;
  late List<String> filteredGenList;

  List<UsableItem> items = [];

  List<UsableItem> itemsToAdd = [
    Potion(),
    SuperPotion(),
    GenerationDetector(),
    PokedexScope(),
  ];

  int currentHp = 100;
  int currentXp = 0;
  int score = 0;
  bool _showInfo = true;
  bool _showGen = false;
  bool _showPokedexNumber = false;

  final _currentGuessesToPointsGained = {
    1: 5,
    2: 4,
    3: 3,
    4: 2,
    5: 1,
  };

  final _tierBoundry = {
    0: "Pokeball",
    10: "Great Ball",
    25: "Ultra Ball",
    40: "Master Ball",
  };

  _WhosThatPokemonMainState(this.generationMap);

  @override
  void dispose() {
    // Dispose any controllers or focus nodes if you have any
    super.dispose();
  }

  final List<Pokemon> pkmnGuessed = [];
  Pokemon? pokemonToGuess;
  PokemonSpecies? pokemonSpecies;

  Map<String, int> generationLower = {
    "gen1": 0,
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

  _clearData() {
    pkmnGuessed.clear();
    pokemonToGuess = null;
    _showGen = false;
    _showPokedexNumber = false;
  }

  _showItemSelectionDialog() {
    List<UsableItem> randomItems = List.from(itemsToAdd)..shuffle();
    randomItems = randomItems.take(3).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level Up! New Item Earned', style: GoogleFonts.inter(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: ListBody(
              children: randomItems.map((item) {
                return ListTile(
                  leading: Image.asset(item.imageAssetPath, width: 50, height: 50),
                  title: Text(item.name, style: GoogleFonts.inter(color: Colors.white)),
                  subtitle: Text(item.description, style: GoogleFonts.inter(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      items.add(item);
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _correctGuess() async {
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
                  pokemonToGuess!.isShiny ? pokemonToGuess!.shinySpriteImageUrl : pokemonToGuess!.spriteImageUrl,
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
                final gainedScore = _currentGuessesToPointsGained[pkmnGuessed.length] ?? 0;

                Navigator.of(context).pop();

                currentXp = (currentXp + gainedScore);
                if (currentXp >= 10) {
                  _showItemSelectionDialog();
                }

                setState(() {
                  currentHp = 100;
                  widget.correctGuessStreak++;
                  score += gainedScore;

                  if (currentXp >= 10) {
                    currentXp = currentXp - 10;
                  }
                  pkmnGuessed.clear();
                  _clearData();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _useItem(UsableItem item, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Use ${item.name}?', style: GoogleFonts.inter(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(item.description, style: GoogleFonts.inter(color: Colors.white)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Use Item', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
                setState(() {
                  switch (item.name) {
                    case "Potion":
                      currentHp = (currentHp + 20).clamp(0, 100);
                      break;
                    case "Super Potion":
                      currentHp = (currentHp + 40).clamp(0, 100);
                      break;

                    case "Generation Detector":
                      _showGen = true;
                      break;

                    case "Pokedex Scope":
                      _showPokedexNumber = true;
                      break;
                    default:
                      break;
                  }
                  items.removeAt(index);
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('White Out', style: GoogleFonts.inter(color: Colors.red)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Game Over! \nYour HP has dropped to 0, resetting your correct guess streak.', style: GoogleFonts.inter(color: Colors.white)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'The Pokémon you were trying to guess was ',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      TextSpan(
                        text: pokemonToGuess!.name,
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '.',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Image.network(
                  pokemonToGuess!.isShiny ? pokemonToGuess!.shinySpriteImageUrl : pokemonToGuess!.spriteImageUrl,
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Return to Main menu', style: GoogleFonts.inter(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Retry', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
                setState(() {
                  currentHp = 100;
                  widget.correctGuessStreak = 0;
                  score = 0;
                  currentXp = 0;
                  items.clear();

                  _clearData();
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

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<Pokemon> _generatePokemon() async {
    var shuffleList = filteredGenList.toList()..shuffle();
    var data = await _getRandomPokemonRawFromGeneration(shuffleList.first);
    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);

    pokemonToGuess ??= randomPokemon;
    pokemonSpecies = await PokemonSpecies.create(pokemonToGuess!.id);

    return pokemonToGuess!;
  }

  _addPokemonToGuessedPokedex(Pokemon pokemon) async {
    var store = intMapStoreFactory.store('pokedex');
    var finder = Finder(filter: Filter.equals('pokemon', pokemon.toString()));
    var recordSnapshots = await store.find(widget.db, finder: finder);

    if (recordSnapshots.isEmpty) {
      await store.add(widget.db, {'pokemon': pokemon.toString()});
    } else if (pokemon.isShiny) {
      var record = recordSnapshots.first;
      await store.record(record.key).put(widget.db, {'pokemon': pokemon.toString()});
    }
  }

  Future<void> _guessPokemon(String name) async {
    final httpResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
    pkmnGuessed.add(Pokemon.fromHttpBody(httpResponse.body));

    if (name.toLowerCase() == pokemonToGuess!.name.toLowerCase()) {
      await _addPokemonToGuessedPokedex(pokemonToGuess!);
      _correctGuess();
    } else {
      setState(() {
        if (currentHp > 0) {
          currentHp -= 20;

          if (currentHp <= 0) {
            _streakBrokenDialog();
            score = 0;
            widget.correctGuessStreak = 0;
          }
        } else {
          if (widget.correctGuessStreak > 0) {
            _streakBrokenDialog();
          }
          score = 0;
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

  _statProgressBar(int statValue, Color barColor) {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: statValue / 255),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.transparent,
                color: barColor,
                minHeight: 10,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$statValue',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _pokemonData(Pokemon pkmData) {
    return [
      Container(
        width: 400,
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
              Row(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HP: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Attack: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Defense: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Special Attack: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Special Defense: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Speed: ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _statProgressBar(pkmData.hp, Colors.green),
                        _statProgressBar(pkmData.attack, Colors.yellow),
                        _statProgressBar(pkmData.defense, Colors.orange),
                        _statProgressBar(pkmData.specialAttack, Colors.cyan),
                        _statProgressBar(pkmData.specialDefense, Colors.blue),
                        _statProgressBar(pkmData.speed, Colors.purple),
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(color: Colors.white),
                    children: [
                      const TextSpan(text: 'Total: '),
                      TextSpan(
                        text: '${pkmData.hp + pkmData.attack + pkmData.defense + pkmData.specialAttack + pkmData.specialDefense + pkmData.speed}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 5),
      PokemonType(pkmData.type1, pkmData.type2),
      const SizedBox(height: 5),
      Visibility(
        visible: _showGen,
        child: Text(
          pokemonSpecies!.generation.replaceAll('-', ' '),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 5),
      Visibility(
        visible: _showPokedexNumber,
        child: Text(
          'Pokedex Number: ${pokemonSpecies!.id}',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 5),
      Visibility(
        visible: false,
        child: Text(
          pokemonSpecies!.name,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      ),
    ];
  }

  _guessingBox(List<String> pkmNameList) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          setState(() {
            // Add padding when the box is focused
            _showInfo = false;
          });
        } else {
          setState(() {
            // Remove padding when the box is not focused
            _showInfo = true;
          });
        }
      },
      child: Autocomplete<String>(
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
          final indexToHighlight = AutocompleteHighlightedOption.of(context);

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
                  LogicalKeySet(LogicalKeyboardKey.arrowDown): const AutocompleteNextOptionIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp): const AutocompletePreviousOptionIntent(),
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bool isHighlighted = index == indexToHighlight;
                    return GestureDetector(
                      onTap: () {
                        onSelected(options.elementAt(index));
                      },
                      child: Container(
                        color: isHighlighted ? Colors.purpleAccent.withOpacity(0.5) : null,
                        child: ListTile(
                          title: Text(
                            options.elementAt(index),
                            style: TextStyle(
                              color: isHighlighted ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
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
          _streakBrokenDialog();
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
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: currentHp / 100),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey,
                color: currentHp <= 20 ? Colors.red : Colors.green,
                minHeight: 10,
              );
            },
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

  _xpBar() {
    return Row(
      children: [
        Text(
          'XP: ',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: currentXp / 10),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey,
                color: Colors.blue,
                minHeight: 10,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$currentXp/10',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  _guessedDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Sprite', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Name', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Type', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('HP', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Attack', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Defense', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Sp. Atk', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Sp. Def', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Speed', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Total', style: GoogleFonts.inter(color: Colors.white))),
        ],
        rows: pkmnGuessed.map((pokemon) {
          return DataRow(cells: [
            DataCell(
              Image.network(
                pokemon.isShiny ? pokemon.shinySpriteImageUrl : pokemon.spriteImageUrl,
                height: 100,
              ),
            ),
            DataCell(Text(pokemon.name, style: GoogleFonts.inter(color: Colors.white))),
            DataCell(PokemonType(pokemon.type1, pokemon.type2)),
            DataCell(Text(pokemon.hp.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(Text(pokemon.attack.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(Text(pokemon.defense.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(Text(pokemon.specialAttack.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(Text(pokemon.specialDefense.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(Text(pokemon.speed.toString(), style: GoogleFonts.inter(color: Colors.white))),
            DataCell(
              Text((pokemon.hp + pokemon.attack + pokemon.defense + pokemon.specialAttack + pokemon.specialDefense + pokemon.speed).toString(),
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ]);
        }).toList(),
      ),
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
                    children: [
                      TextSpan(text: "Guessing Tier: ", style: GoogleFonts.inter(fontWeight: FontWeight.normal)),
                      TextSpan(
                        text: _tierBoundry.entries.where((entry) => score >= entry.key).map((entry) => entry.value).last,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Score: $score",
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
              Align(
                alignment: Alignment.centerLeft,
                child: _xpBar(),
              ),
              const SizedBox(height: 5),
              _giveupButton(),
            ],
          ),
        ),
      ),
    );
  }

  _itemBag() {
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
                "Bag",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(
                      items[index].imageAssetPath,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      items[index].name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      _useItem(items[index], index);
                    },
                  );
                },
              ),
              if (items.isEmpty)
                Text(
                  "No items",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _logo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth > 900 ? 40 : 20;
        return Align(
          alignment: Alignment.topLeft,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: fontSize,
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
      },
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
                          db: widget.db,
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
                              _guessedDataTable(),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            _statBox(),
                            const SizedBox(height: 10),
                            _itemBag(),
                          ],
                        ),
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
            Expanded(
              child: ListView(
                children: [
                  _statBox(),
                  const SizedBox(height: 10),
                  _itemBag(),
                  const SizedBox(height: 10),
                  GenerationSelector(
                    generationMap: generationMap,
                    db: widget.db,
                  ),
                ],
              ),
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
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Score: $score",
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
                                  Align(
                                    alignment: Alignment.center,
                                    child: _xpBar(),
                                  ),
                                  const SizedBox(height: 10),
                                  Visibility(
                                    visible: _showInfo,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: _pokemonData(snapshot.data!),
                                      ),
                                    ),
                                  )
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
                        _guessedDataTable(),
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
        if (constraints.maxWidth > 900) {
          return _desktopLayout();
        } else {
          return _mobileLayout();
        }
      },
    );
  }
}
