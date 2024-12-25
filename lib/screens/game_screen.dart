import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/items/generation_detector.dart';
import 'package:whos_that_pokemon/items/pokedex_scope.dart';
import 'package:whos_that_pokemon/items/potion.dart';
import 'package:whos_that_pokemon/items/super_potion.dart';
import 'package:whos_that_pokemon/items/usable_item.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/pokemon_species.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/widgets/pokemon_guessed_table.dart';
import 'package:whos_that_pokemon/widgets/pokemon_search_box.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';
import 'dart:math';
import 'dart:convert';
import 'package:sembast/sembast.dart';

// ignore: must_be_immutable
class GameScreen extends ConsumerStatefulWidget {
  final Database db;
  late final Map<String, bool> generationMap;
  int correctGuessStreak;

  GameScreen(this.generationMap, this.correctGuessStreak, this.db, {super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenMainState(generationMap);
}

class _GameScreenMainState extends ConsumerState<GameScreen> {
  final Map<String, bool> generationMap;
  late final PokemonGenerator _pokemonGenerator;

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

  _GameScreenMainState(this.generationMap);

  @override
  void initState() {
    super.initState();
    _pokemonGenerator = PokemonGenerator();

    _pokemonGenerator.generatePokemon(ref);
    items.addAll(itemsToAdd);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _clearData() {
    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final guessedPokemon = guessedPokemonNotifier.state;

    guessedPokemon.clear();
    guessedPokemonNotifier.update((state) => guessedPokemon);

    _pokemonGenerator.generatePokemon(ref).then((value) => null);
  }

  Future<void> _guessPokemon(String name) async {
    final httpResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));

    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final guessedPokemon = guessedPokemonNotifier.state;

    guessedPokemon.add(Pokemon.fromHttpBody(httpResponse.body));
    guessedPokemonNotifier.update((state) => guessedPokemon);

    // if (name.toLowerCase() == pokemonToGuess!.name.toLowerCase()) {
    //   await _addPokemonToGuessedPokedex(pokemonToGuess!);
    //   _correctGuess();
    // } else {
    //   setState(() {
    //     if (currentHp > 0) {
    //       currentHp -= 20;

    //       if (currentHp <= 0) {
    //         _streakBrokenDialog();
    //         score = 0;
    //         widget.correctGuessStreak = 0;
    //       }
    //     } else {
    //       if (widget.correctGuessStreak > 0) {
    //         _streakBrokenDialog();
    //       }
    //       score = 0;
    //       widget.correctGuessStreak = 0;
    //     }
    //   });
    // }

    setState(() {});
  }

  _debugPokemon(Pokemon? pokemonToGuess) {
    return Visibility(
      visible: !kReleaseMode,
      child: Column(
        children: [
          Text("Pokemon to guess: ${pokemonToGuess?.name ?? "Loading..."}", textAlign: TextAlign.center),
          if (pokemonToGuess != null)
            Image.network(
              pokemonToGuess.shinySpriteImageUrl,
              width: 100,
              height: 100,
            ),
          ElevatedButton(
              onPressed: () async {
                _clearData();
              },
              child: const Text("Refresh")),
        ],
      ),
    );
  }

  _mobileLayout(Pokemon? pokemonToGuess) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 16,
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
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _key.currentState!.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  SizedBox(height: 10),
                  GenerationSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _debugPokemon(pokemonToGuess),
            PokemonSearchBox(guessPokemonFunction: _guessPokemon),
            const PokemonGuessedTable(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    ref.listen<Map<String, bool>>(generationMapProvider, (previous, next) {
      if (previous != next) {
        _clearData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Generation map has changed!', style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
          ),
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return _mobileLayout(pokemonToGuess);
      },
    );
  }
}
