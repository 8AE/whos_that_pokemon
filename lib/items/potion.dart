import 'package:whos_that_pokemon/items/usable_item.dart';

class Potion implements UsableItem {
  @override
  final String name = 'Potion';
  @override
  final String description = 'A spray-type medicine for treating wounds. It restores HP by 20 points.';
  @override
  final String imageAssetPath = 'assets/items/potion.png';

  Potion();
}
