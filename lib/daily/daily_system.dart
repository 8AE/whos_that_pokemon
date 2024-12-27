import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/providers.dart';

class DailySystem {
  static void correctGuess(WidgetRef ref) {
    ref.read(correctGuessProvider.notifier).update((state) => true);
  }

  static void wrongGuess(WidgetRef ref) {}

  static void resetSystem(WidgetRef ref) {
    ref.read(guessedPokemonListProvider.notifier).update((state) => []);
    ref.read(currentHealthProvider.notifier).update((state) => 100);
    ref.read(currentXpProvider.notifier).update((state) => 0);
    ref.read(currentScoreProvider.notifier).update((state) => 0);
    ref.read(correctGuessStreakProvider.notifier).update((state) => 0);
    ref.read(gameOverProvider.notifier).update((state) => false);
    ref.read(showGenerationHintProvider.notifier).update((state) => false);
    ref.read(showPokedexNumberHintProvider.notifier).update((state) => false);
    ref.read(gainItemProvider.notifier).update((state) => false);
    ref.read(correctGuessProvider.notifier).update((state) => false);
    ref.read(itemListProvider.notifier).update((state) => []);
  }
}
