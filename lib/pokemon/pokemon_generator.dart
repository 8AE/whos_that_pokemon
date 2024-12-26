import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:whos_that_pokemon/pokemon_species.dart';
import 'package:whos_that_pokemon/providers.dart';

class PokemonGenerator {
  static final Map<String, int> _generationLower = {
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

  static final Map<String, int> _generationUpper = {
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

  static List<String> filteredGenList(WidgetRef ref) {
    final generationMap = ref.read(generationMapProvider);

    return generationMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  }

  static Future<List<String>> _generatePokemonListWithGen(String generation) async {
    var pokemonListRaw = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=${_generationUpper[generation]! - _generationLower[generation]!}&offset=${_generationLower[generation]}'));
    var jsonData = jsonDecode(pokemonListRaw.body);
    List<String> pkmnList = [];

    for (var pokemonEntry in jsonData['results']) {
      pkmnList.add(pokemonEntry['name']);
    }

    return pkmnList;
  }

  static Future<List<String>> _generatePokemonList(WidgetRef ref) async {
    List<String> pkmnList = [];
    for (var generation in filteredGenList(ref)) {
      pkmnList.addAll(await _generatePokemonListWithGen(generation));
    }

    return pkmnList;
  }

  static Future<http.Response> _getRandomPokemonRawFromGeneration(String generation) {
    var intValue = _generationLower[generation]! + Random().nextInt((_generationUpper[generation]! + 1) - _generationLower[generation]!);

    return http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$intValue'));
  }

  static Future<void> generatePokemon(WidgetRef ref, {int? testPokemonNumber}) async {
    var shuffleList = filteredGenList(ref).toList()..shuffle();
    var data;

    if (testPokemonNumber != null) {
      data = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$testPokemonNumber'));
    } else {
      data = await _getRandomPokemonRawFromGeneration(shuffleList.first);
    }

    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);
    final pokemonSpecies = await PokemonSpecies.create(randomPokemon.id);

    ref.read(pokemonToGuessProvider.notifier).update((state) => randomPokemon);
    ref.read(pokemonSpeciesProvider.notifier).update((state) => pokemonSpecies);

    var pokemonList = ref.read(pokemonNameListProvider);
    pokemonList.clear();
    pokemonList.addAll(await _generatePokemonList(ref));
    ref.read(pokemonNameListProvider.notifier).update((state) => pokemonList);
  }

  static Future<void> generateDailyPokemon(WidgetRef ref) async {
    var now = DateTime.now();
    var dailyPokemonNumber = (now.month * 31 + now.day) % 1025 + 1;
    var data = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$dailyPokemonNumber'));

    Pokemon randomPokemon = Pokemon.fromHttpBody(data.body);
    final pokemonSpecies = await PokemonSpecies.create(randomPokemon.id);

    ref.read(pokemonToGuessProvider.notifier).update((state) => randomPokemon);
    ref.read(pokemonSpeciesProvider.notifier).update((state) => pokemonSpecies);

    ref.read(generationMapProvider.notifier).update((state) {
      return state.map((key, value) => MapEntry(key, true));
    });

    var pokemonList = ref.read(pokemonNameListProvider);
    pokemonList.clear();
    pokemonList.addAll(await _generatePokemonList(ref));
    ref.read(pokemonNameListProvider.notifier).update((state) => pokemonList);
  }
}
