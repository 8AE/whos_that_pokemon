import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/providers.dart';

class DailySystem {
  static void correctGuess(WidgetRef ref) {
    ref.read(correctGuessProvider.notifier).update((state) => true);
  }

  static void wrongGuess(WidgetRef ref) {}

  static void resetSystem(WidgetRef ref) {
    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final guessedPokemon = guessedPokemonNotifier.state;

    guessedPokemon.clear();
    guessedPokemonNotifier.update((state) => guessedPokemon);

    final currentHealthNotifier = ref.read(currentHealthProvider.notifier);
    currentHealthNotifier.update((state) => 100);

    final currentXpNotifier = ref.read(currentXpProvider.notifier);
    currentXpNotifier.update((state) => 0);

    final currentScoreNotifier = ref.read(currentScoreProvider.notifier);
    currentScoreNotifier.update((state) => 0);

    final correctGuessStreakNotifier = ref.read(correctGuessStreakProvider.notifier);
    correctGuessStreakNotifier.update((state) => 0);

    final gameOverNotifier = ref.read(gameOverProvider.notifier);
    gameOverNotifier.update((state) => false);
    ref.read(showGenerationHintProvider.notifier).update((state) => false);
    ref.read(showPokedexNumberHintProvider.notifier).update((state) => false);
    ref.read(gainItemProvider.notifier).update((state) => false);
    ref.read(correctGuessProvider.notifier).update((state) => false);
    ref.read(itemListProvider.notifier).update((state) => []);
  }
}
