import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/items/generation_detector.dart';
import 'package:whos_that_pokemon/items/pokedex_scope.dart';
import 'package:whos_that_pokemon/items/potion.dart';
import 'package:whos_that_pokemon/items/super_potion.dart';
import 'package:whos_that_pokemon/items/usable_item.dart';
import 'package:whos_that_pokemon/providers.dart';

class ItemManager {
  static final List<UsableItem> _itemsToAdd = [
    Potion(),
    SuperPotion(),
    GenerationDetector(),
    PokedexScope(),
  ];

  static List<UsableItem> getItems(int numberOfItems) {
    List<UsableItem> randomItems = List.from(_itemsToAdd)..shuffle();
    randomItems = randomItems.take(numberOfItems).toList();
    return randomItems;
  }

  static void useItem(WidgetRef ref, UsableItem item) {
    final itemListNotifier = ref.read(itemListProvider.notifier);
    final itemList = itemListNotifier.state;

    final itemLocation = itemList.indexWhere((element) => element.name == item.name);

    itemList.removeAt(itemLocation);
    itemListNotifier.update((state) => itemList);

    final currentHpNotifier = ref.read(currentHealthProvider.notifier);
    var currentHp = currentHpNotifier.state;

    final showGenerationHintNotifier = ref.read(showGenerationHintProvider.notifier);
    final showPokedexNumberHintNotifier = ref.read(showPokedexNumberHintProvider.notifier);

    switch (item.name) {
      case "Potion":
        currentHp = (currentHp + 20).clamp(0, 100);
        break;
      case "Super Potion":
        currentHp = (currentHp + 40).clamp(0, 100);
        break;

      case "Generation Detector":
        showGenerationHintNotifier.update((state) => true);
        break;

      case "Pokedex Scope":
        showPokedexNumberHintNotifier.update((state) => true);
        break;
      default:
        break;
    }

    currentHpNotifier.update((state) => currentHp);
  }

  static void addItem(WidgetRef ref, UsableItem item) {
    final itemListNotifier = ref.read(itemListProvider.notifier);
    final itemList = itemListNotifier.state;

    itemList.add(item);
    itemListNotifier.update((state) => itemList);
  }
}
