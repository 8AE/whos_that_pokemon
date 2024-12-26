import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/items/usable_item.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon_species.dart';

final pokemonToGuessProvider = StateProvider<Pokemon?>((ref) => null);
final pokemonSpeciesProvider = StateProvider<PokemonSpecies?>((ref) => null);

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

final currentHealthProvider = StateProvider<int>((ref) => 100);
final currentXpProvider = StateProvider<int>((ref) => 0);
final currentScoreProvider = StateProvider<int>((ref) => 0);
final correctGuessStreakProvider = StateProvider<int>((ref) => 0);

final gameOverProvider = StateProvider<bool>((ref) => false);
final gainItemProvider = StateProvider<bool>((ref) => false);
final correctGuessProvider = StateProvider<bool>((ref) => false);

final itemListProvider = StateProvider<List<UsableItem>>((ref) => []);

final guessingBoxIsFocusedProvider = StateProvider<bool>((ref) => false);
final showGenerationHintProvider = StateProvider<bool>((ref) => false);
final showPokedexNumberHintProvider = StateProvider<bool>((ref) => false);
