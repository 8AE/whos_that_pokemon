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

  final List<Pokemon> pkmnGuessed = [];
  Pokemon? pokemonToGuess;
  PokemonSpecies? pokemonSpecies;

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
                children: [
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pokemon to guess: ${pokemonToGuess?.name ?? "Loading..."}"),
            if (pokemonToGuess != null)
              Image.network(
                pokemonToGuess.shinySpriteImageUrl,
                width: 200,
                height: 200,
              ),
            ElevatedButton(
                onPressed: () async {
                  await _pokemonGenerator.generatePokemon(ref);
                },
                child: const Text("Refresh")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return _mobileLayout(pokemonToGuess);
      },
    );
  }
}
