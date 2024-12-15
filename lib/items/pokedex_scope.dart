import 'package:whos_that_pokemon/items/usable_item.dart';

class PokedexScope implements UsableItem {
  @override
  final String name = 'Pokedex Scope';
  @override
  final String description = 'A device that can reveal Pokedex entry of a Pokemon.';
  @override
  final String imageAssetPath = 'assets/no-pokemon.png';

  PokedexScope();
}
