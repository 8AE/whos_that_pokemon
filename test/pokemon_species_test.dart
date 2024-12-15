import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whos_that_pokemon/pokemon_species.dart';

import 'pokemon_species_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('PokemonSpecies', () {
    test('create returns a PokemonSpecies object', () async {
      final client = MockClient();
      final response = {
        'name': 'bulbasaur',
        'id': 1,
        'generation': {'name': 'generation-i'},
        'is_legendary': false,
        'is_mythical': false,
        'capture_rate': 45,
      };

      when(client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/1'))).thenAnswer((_) async => http.Response(jsonEncode(response), 200));

      final pokemonSpecies = await PokemonSpecies.create(1);

      expect(pokemonSpecies.name, 'bulbasaur');
      expect(pokemonSpecies.id, 1);
      expect(pokemonSpecies.generation, 'generation-i');
      expect(pokemonSpecies.isLegendary, false);
      expect(pokemonSpecies.isMythical, false);
      expect(pokemonSpecies.captureRate, 45);
    });
  });
}
