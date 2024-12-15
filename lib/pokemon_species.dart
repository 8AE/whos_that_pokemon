import 'dart:convert';

import 'package:http/http.dart' as http;

class PokemonSpecies {
  final String name;
  final int id;
  final String generation;
  final bool isLegendary;
  final bool isMythical;
  final int captureRate;

  PokemonSpecies._create(
    this.name,
    this.id,
    this.generation,
    this.isLegendary,
    this.isMythical,
    this.captureRate,
  );

  static Future<PokemonSpecies> create(int id) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/${id}'));
    final jsonData = jsonDecode(response.body);

    return PokemonSpecies._create(
      jsonData['name'],
      jsonData['id'],
      jsonData['generation']['name'],
      jsonData['is_legendary'],
      jsonData['is_mythical'],
      jsonData['capture_rate'],
    );
  }
}
