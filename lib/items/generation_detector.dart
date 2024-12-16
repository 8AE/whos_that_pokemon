import 'package:whos_that_pokemon/items/usable_item.dart';

class GenerationDetector implements UsableItem {
  @override
  final String name = 'Generation Detector';
  @override
  final String description = 'A device that can detect the generation of a Pokémon.';
  @override
  final String imageAssetPath = 'assets/items/town-map.webp';

  GenerationDetector();
}
