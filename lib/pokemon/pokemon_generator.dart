import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/providers.dart';

class PokemonGenerator {
  final Map<String, int> _generationLower = {
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

  final Map<String, int> _generationUpper = {
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

  PokemonGenerator();

  List<String> filteredGenList(WidgetRef ref) {
    final generationMap = ref.read(generationMapProvider);

    return generationMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  }

  Future<http.Response> _getRandomPokemonRawFromGeneration(String generation) {
    var intValue = _generationLower[generation]! + Random().nextInt((_generationUpper[generation]! + 1) - _generationLower[generation]!);

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  Future<void> generatePokemon(WidgetRef ref, {int? testPokemonNumber}) async {
    var shuffleList = filteredGenList(ref).toList()..shuffle();
    var data;

    if (testPokemonNumber != null) {
      data = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$testPokemonNumber'));
    } else {
      data = await _getRandomPokemonRawFromGeneration(shuffleList.first);
    }

    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);
    ref.read(pokemonToGuessProvider.notifier).update((state) => randomPokemon);
  }
}
