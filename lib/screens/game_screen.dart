import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/gauntlet/gauntlet_correct_guess.dart';
import 'package:whos_that_pokemon/gauntlet/gauntlet_system.dart';
import 'package:whos_that_pokemon/items/generation_detector.dart';
import 'package:whos_that_pokemon/items/pokedex_scope.dart';
import 'package:whos_that_pokemon/items/potion.dart';
import 'package:whos_that_pokemon/items/super_potion.dart';
import 'package:whos_that_pokemon/items/usable_item.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/current_hp_bar.dart';
import 'package:whos_that_pokemon/widgets/current_xp_bar.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/widgets/pokemon_guessed_table.dart';
import 'package:whos_that_pokemon/widgets/pokemon_info.dart';
import 'package:whos_that_pokemon/widgets/pokemon_search_box.dart';
import 'package:sembast/sembast.dart';
import 'package:whos_that_pokemon/widgets/pokemon_stat_box.dart';
import 'package:whos_that_pokemon/widgets/pokemon_stat_table.dart';

// ignore: must_be_immutable
class GameScreen extends ConsumerStatefulWidget {
  final Database db;

  GameScreen(this.db, {super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenMainState();
}

class _GameScreenMainState extends ConsumerState<GameScreen> {
  late final PokemonGenerator _pokemonGenerator;

  List<UsableItem> items = [];

  List<UsableItem> itemsToAdd = [
    Potion(),
    SuperPotion(),
    GenerationDetector(),
    PokedexScope(),
  ];

  bool _showInfo = true;
  bool _showGen = false;
  bool _showPokedexNumber = false;

  _GameScreenMainState();

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

  _correctGuessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const GauntletCorrectGuess();
      },
    );
  }

  _gameOverDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const GauntletCorrectGuess();
      },
    );
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

    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final guessedPokemon = guessedPokemonNotifier.state;
    guessedPokemon.add(Pokemon.fromHttpBody(httpResponse.body));
    guessedPokemonNotifier.update((state) => guessedPokemon);

    final pokemonToGuess = ref.read(pokemonToGuessProvider);

    if (name.toLowerCase() == pokemonToGuess!.name.toLowerCase()) {
      await _addPokemonToGuessedPokedex(pokemonToGuess);
      GauntletSystem.correctGuess(ref);
      _correctGuessDialog();
      await _pokemonGenerator.generatePokemon(ref);
    } else {
      GauntletSystem.wrongGuess(ref);
    }

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
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _mobileLayout(Pokemon? pokemonToGuess, int correctGuessStreak, int currentScore) {
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
                fontSize: 20,
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
                  PokemonStatBox(),
                  SizedBox(height: 10),
                  GenerationSelector(),
                  SizedBox(height: 10),
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
            Align(
              alignment: Alignment.center,
              child: Text(
                "Correct Guess Streak: ${correctGuessStreak.toString()}",
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
                "Score: $currentScore",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const CurrentHpBar(),
            const CurrentXpBar(),
            const SizedBox(height: 10),
            Visibility(
              visible: pokemonToGuess != null,
              child: const PokemonInfo(),
            ),
            const SizedBox(height: 10),
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
    final correctGuessStreak = ref.watch(correctGuessStreakProvider);
    final currentScore = ref.watch(currentScoreProvider);

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

    ref.listen<bool>(gameOverProvider, (previous, next) {
      if (next) {
        _gameOverDialog();
        GauntletSystem.resetSystem(ref);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return _mobileLayout(pokemonToGuess, correctGuessStreak, currentScore);
      },
    );
  }
}
