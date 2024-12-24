import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'pokemon_generator_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late PokemonGenerator pokemonGenerator;
  final mockHttpClient = MockClient();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    pokemonGenerator = PokemonGenerator(generationMap: {
      "gen1": true,
      "gen2": false,
      "gen3": false,
      "gen4": false,
      "gen5": false,
      "gen6": false,
      "gen7": false,
      "gen8": false,
      "gen9": false,
    });
  });

  test('filteredGenList returns only enabled generations', () {
    expect(pokemonGenerator.filteredGenList(), ["gen1"]);
  });

  test('changeGenerationMap updates the generation map', () {
    pokemonGenerator.changeGenerationMap({
      "gen1": false,
      "gen2": true,
      "gen3": true,
      "gen4": false,
      "gen5": false,
      "gen6": false,
      "gen7": false,
      "gen8": false,
      "gen9": false,
    });
    expect(pokemonGenerator.filteredGenList(), ["gen2", "gen3"]);
  });

  test('generatePokemon updates pokemonToGuessProvider', () async {
    const response = '''
    {
      "id": 1,
      "name": "bulbasaur",
      "types": [
      {"type": {"name": "grass"}},
      {"type": {"name": "poison"}}
      ],
      "sprites": {
      "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
      "front_shiny": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"
      },
      "stats": [
      {"base_stat": 45}, {"base_stat": 49}, {"base_stat": 49},
      {"base_stat": 65}, {"base_stat": 65}, {"base_stat": 45}
      ]
    }''';

    when(mockHttpClient.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1'))).thenAnswer((_) async => http.Response(jsonEncode(response), 200));

    await pokemonGenerator.generatePokemon(container, testPokemonNumber: 1);

    final pokemon = container.read(pokemonToGuessProvider);
    expect(pokemon?.name, "bulbasaur");
  });
}
