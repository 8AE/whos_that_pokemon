import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/pokemon.dart';

final pokemonToGuessProvider = StateProvider<Pokemon?>((ref) => null);

final generationMapProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    "gen1": true,
    "gen2": true,
    "gen3": true,
    "gen4": true,
    "gen5": true,
    "gen6": true,
    "gen7": true,
    "gen8": true,
    "gen9": true,
  };
});

final guessedPokemonListProvider = StateProvider<List<Pokemon>>((ref) => []);

final pokemonNameListProvider = StateProvider<List<String>>((ref) => []);
