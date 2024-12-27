import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/daily/daily_correct_guess.dart';
import 'package:whos_that_pokemon/daily/daily_system.dart';
import 'package:whos_that_pokemon/game_mode/game_mode.dart';
import 'package:whos_that_pokemon/gauntlet/gauntlet_correct_guess.dart';
import 'package:whos_that_pokemon/gauntlet/gauntlet_select_item.dart';
import 'package:whos_that_pokemon/gauntlet/gauntlet_system.dart';
import 'package:whos_that_pokemon/gauntlet/gauntlet_wrong_guess.dart';
import 'package:whos_that_pokemon/pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_species.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/current_hp_bar.dart';
import 'package:whos_that_pokemon/widgets/current_xp_bar.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/widgets/item_bag.dart';
import 'package:whos_that_pokemon/widgets/pokemon_guessed_table.dart';
import 'package:whos_that_pokemon/widgets/pokemon_info.dart';
import 'package:whos_that_pokemon/widgets/pokemon_search_box.dart';
import 'package:sembast/sembast.dart';
import 'package:whos_that_pokemon/widgets/pokemon_stat_box.dart';

// ignore: must_be_immutable
class GameScreen extends ConsumerStatefulWidget {
  final Database db;
  final GameMode gameMode;

  const GameScreen({required this.db, required this.gameMode, super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenMainState();
}

class _GameScreenMainState extends ConsumerState<GameScreen> {
  _GameScreenMainState();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.gameMode == GameMode.gauntlet) {
      PokemonGenerator.generatePokemon(ref).then((value) => null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GauntletSystem.resetSystem(ref);
        setState(() {});
      });
    } else {
      PokemonGenerator.generateDailyPokemon(ref).then((value) => null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DailySystem.resetSystem(ref);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _correctGuessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (widget.gameMode == GameMode.gauntlet) {
          return const GauntletCorrectGuess();
        } else {
          return const DailyCorrectGuess();
        }
      },
    );
  }

  _gameOverDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GauntletWrongGuess();
      },
    );
  }

  _gainItemDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GauntLetGetItem();
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
      if (widget.gameMode == GameMode.gauntlet) {
        GauntletSystem.correctGuess(ref);
      } else {
        DailySystem.correctGuess(ref);
      }
    } else {
      if (widget.gameMode == GameMode.gauntlet) {
        GauntletSystem.wrongGuess(ref);
      } else {
        DailySystem.wrongGuess(ref);
      }
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
                GauntletSystem.resetSystem(ref);
              },
              child: const Text("Refresh")),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _mobileLayout(Pokemon? pokemonToGuess, int correctGuessStreak, int currentScore, PokemonSpecies? pokemonSpecies, bool searchBoxIsFocused) {
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
        leading: widget.gameMode == GameMode.gauntlet
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _key.currentState!.openDrawer();
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      drawer: widget.gameMode == GameMode.gauntlet
          ? Drawer(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: const [
                        PokemonStatBox(),
                        SizedBox(height: 10),
                        ItemBag(),
                        SizedBox(height: 10),
                        GenerationSelector(),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
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
              visible: pokemonToGuess != null && pokemonSpecies != null && !searchBoxIsFocused,
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

  _desktopLayout(Pokemon? pokemonToGuess, int correctGuessStreak, int currentScore, PokemonSpecies? pokemonSpecies) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            textAlign: TextAlign.left,
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
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: widget.gameMode == GameMode.gauntlet,
              child: const Column(
                children: [
                  GenerationSelector(),
                ],
              ),
            ),
            Visibility(
              visible: widget.gameMode == GameMode.daily,
              child: const Column(
                children: [
                  SizedBox(width: 300),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // padding: const EdgeInsets.all(16.0),
                children: [
                  _debugPokemon(pokemonToGuess),
                  Visibility(
                    visible: pokemonToGuess != null && pokemonSpecies != null,
                    child: const PokemonInfo(),
                  ),
                  const SizedBox(height: 10),
                  PokemonSearchBox(guessPokemonFunction: _guessPokemon),
                  const PokemonGuessedTable(),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: widget.gameMode == GameMode.gauntlet,
              child: const Column(
                children: [
                  PokemonStatBox(),
                  SizedBox(height: 10),
                  ItemBag(),
                ],
              ),
            ),
            Visibility(
              visible: widget.gameMode == GameMode.daily,
              child: const Column(
                children: [
                  SizedBox(width: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);
    final pokemonSpecies = ref.watch(pokemonSpeciesProvider);
    final correctGuessStreak = ref.watch(correctGuessStreakProvider);
    final currentScore = ref.watch(currentScoreProvider);
    final searchBoxIsFocused = ref.watch(guessingBoxIsFocusedProvider);

    if (widget.gameMode == GameMode.gauntlet) {
      ref.listen<Map<String, bool>>(generationMapProvider, (previous, next) {
        if (previous != next) {
          setState(() {
            GauntletSystem.resetSystem(ref);
            PokemonGenerator.generatePokemon(ref).then((value) => null);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.purpleAccent,
              content: Text('Game Reset', style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
            ),
          );
        }
      });

      ref.listen<bool>(gameOverProvider, (previous, next) {
        if (next) {
          if (_key.currentState!.isDrawerOpen) {
            Navigator.of(context).pop();
          }

          ref.read(gameOverProvider.notifier).update((state) => false);
          _gameOverDialog();
          GauntletSystem.resetSystem(ref);
        }
      });

      ref.listen<bool>(gainItemProvider, (previous, next) {
        if (next) {
          ref.read(gainItemProvider.notifier).update((state) => false);
          _gainItemDialog();
        }
      });
    }

    ref.listen<bool>(correctGuessProvider, (previous, next) {
      if (next) {
        ref.read(correctGuessProvider.notifier).update((state) => false);
        _correctGuessDialog();
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _desktopLayout(pokemonToGuess, correctGuessStreak, currentScore, pokemonSpecies);
        } else {
          return _mobileLayout(pokemonToGuess, correctGuessStreak, currentScore, pokemonSpecies, searchBoxIsFocused);
        }
      },
    );
  }
}
