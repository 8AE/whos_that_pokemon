import 'package:whos_that_pokemon/items/usable_item.dart';

class LegendaryGem implements UsableItem {
  @override
  final String name = 'Legendary Gem';
  @override
  final String description = 'A gem that reveals the true form of a Legendary Pokémon.';
  @override
  final String imageAssetPath = 'assets/no-pokemon.png';

  LegendaryGem();
}
