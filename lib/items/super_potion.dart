import 'package:whos_that_pokemon/items/usable_item.dart';

class SuperPotion implements UsableItem {
  @override
  final String name = 'Super Potion';
  @override
  final String description = 'A spray-type medicine for treating wounds. It restores HP by 40 points.';
  @override
  final String imageAssetPath = 'assets/items/super-potion.png';

  SuperPotion();
}
