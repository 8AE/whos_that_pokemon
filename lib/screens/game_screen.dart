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

class GameScreen extends ConsumerWidget {
  final Database db;
  final GameMode gameMode;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  GameScreen({required this.db, required this.gameMode, super.key});

  Future<void> _addPokemonToGuessedPokedex(Database db, Pokemon pokemon) async {
    var store = intMapStoreFactory.store('pokedex');
    var finder = Finder(filter: Filter.equals('pokemon', pokemon.toString()));
    var recordSnapshots = await store.find(db, finder: finder);

    if (recordSnapshots.isEmpty) {
      await store.add(db, {'pokemon': pokemon.toString()});
    } else if (pokemon.isShiny) {
      var record = recordSnapshots.first;
      await store.record(record.key).put(db, {'pokemon': pokemon.toString()});
    }
  }

  Future<void> _addPokemonToDailyGuessList(Database db, Pokemon pokemon) async {
    var store = intMapStoreFactory.store('daily-pokemon');
    await store.add(db, {'pokemon': pokemon.toString()});
  }

  Future<void> _storeSolvedPokemon(Database db, Pokemon pokemon) async {
    var store = StoreRef.main();
    await store.record('daily_solved_pokemon').put(db, pokemon.toString());
    await store.record('daily_solved').put(db, true);
  }

  Future<void> _guessPokemon(BuildContext context, WidgetRef ref, String name) async {
    final httpResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));

    final guessedPokemon = Pokemon.fromHttpBody(httpResponse.body);

    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    guessedPokemonNotifier.update((state) => [
          ...state,
          guessedPokemon,
        ]);

    final pokemonToGuess = ref.read(pokemonToGuessProvider);

    if (gameMode == GameMode.daily) {
      await _addPokemonToDailyGuessList(db, guessedPokemon);
    }

    if (name.toLowerCase() == pokemonToGuess!.name.toLowerCase()) {
      await _addPokemonToGuessedPokedex(db, pokemonToGuess);
      if (gameMode == GameMode.gauntlet) {
        GauntletSystem.correctGuess(ref);
      } else {
        DailySystem.correctGuess(ref);
      }
    } else {
      if (gameMode == GameMode.gauntlet) {
        GauntletSystem.wrongGuess(ref);
      } else {
        DailySystem.wrongGuess(ref);
      }
    }
  }

  void _correctGuessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (gameMode == GameMode.gauntlet) {
          return const GauntletCorrectGuess();
        } else {
          return const DailyCorrectGuess();
        }
      },
    );
  }

  void _gameOverDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GauntletWrongGuess();
      },
    );
  }

  void _gainItemDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GauntLetGetItem();
      },
    );
  }

  Widget _debugPokemon(WidgetRef ref, Pokemon? pokemonToGuess) {
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

  Widget _mobileLayout(BuildContext context, WidgetRef ref, Pokemon? pokemonToGuess, int correctGuessStreak, int currentScore, PokemonSpecies? pokemonSpecies,
      bool searchBoxIsFocused) {
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
        leading: gameMode == GameMode.gauntlet
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
      drawer: gameMode == GameMode.gauntlet
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
            _debugPokemon(ref, pokemonToGuess),
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
            Visibility(
              visible: !ref.read(correctGuessProvider),
              child: PokemonSearchBox(guessPokemonFunction: (name) => _guessPokemon(context, ref, name)),
            ),
            const PokemonGuessedTable(),
          ],
        ),
      ),
    );
  }

  Widget _desktopLayout(
      BuildContext context, WidgetRef ref, Pokemon? pokemonToGuess, int correctGuessStreak, int currentScore, PokemonSpecies? pokemonSpecies) {
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
              visible: gameMode == GameMode.gauntlet,
              child: const Column(
                children: [
                  GenerationSelector(),
                ],
              ),
            ),
            Visibility(
              visible: gameMode == GameMode.daily,
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
                children: [
                  _debugPokemon(ref, pokemonToGuess),
                  Visibility(
                    visible: pokemonToGuess != null && pokemonSpecies != null,
                    child: const PokemonInfo(),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: !ref.read(correctGuessProvider),
                    child: PokemonSearchBox(guessPokemonFunction: (name) => _guessPokemon(context, ref, name)),
                  ),
                  Visibility(
                    visible: ref.read(correctGuessProvider) && gameMode == GameMode.daily,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final guessedPokemonList = ref.read(guessedPokemonListProvider);
                        final shareText = "I guessed the Daily Pokémon in ${guessedPokemonList.length} tries! Can you beat me?";
                        // Share.share(shareText);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                    ),
                  ),
                  const PokemonGuessedTable(),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: gameMode == GameMode.gauntlet,
              child: const Column(
                children: [
                  PokemonStatBox(),
                  SizedBox(height: 10),
                  ItemBag(),
                ],
              ),
            ),
            Visibility(
              visible: gameMode == GameMode.daily,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);
    final pokemonSpecies = ref.watch(pokemonSpeciesProvider);
    final correctGuessStreak = ref.watch(correctGuessStreakProvider);
    final currentScore = ref.watch(currentScoreProvider);
    final searchBoxIsFocused = ref.watch(guessingBoxIsFocusedProvider);

    if (gameMode == GameMode.gauntlet) {
      ref.listen<Map<String, bool>>(generationMapProvider, (previous, next) {
        if (previous != next) {
          GauntletSystem.resetSystem(ref);
          PokemonGenerator.generatePokemon(ref).then((value) => null);

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
          _gameOverDialog(context);
          GauntletSystem.resetSystem(ref);
        }
      });

      ref.listen<bool>(gainItemProvider, (previous, next) {
        if (next) {
          ref.read(gainItemProvider.notifier).update((state) => false);
          _gainItemDialog(context);
        }
      });
    }

    ref.listen<bool>(correctGuessProvider, (previous, next) {
      if (next) {
        ref.read(correctGuessProvider.notifier).update((state) => false);

        if (gameMode == GameMode.daily) {
          _storeSolvedPokemon(db, pokemonToGuess!).then((value) => null);
        }
        _correctGuessDialog(context);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _desktopLayout(context, ref, pokemonToGuess, correctGuessStreak, currentScore, pokemonSpecies);
        } else {
          return _mobileLayout(context, ref, pokemonToGuess, correctGuessStreak, currentScore, pokemonSpecies, searchBoxIsFocused);
        }
      },
    );
  }
}
