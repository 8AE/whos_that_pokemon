import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/providers.dart';

class GauntletSystem {
  static const _currentGuessesToPointsGained = {
    1: 5,
    2: 4,
    3: 3,
    4: 2,
    5: 1,
  };

  static void correctGuess(WidgetRef ref) {
    final pokemonGuessed = ref.read(guessedPokemonListProvider);
    final gainedScore = _currentGuessesToPointsGained[pokemonGuessed.length] ?? 0;

    final currentScoreNotifier = ref.read(currentScoreProvider.notifier);
    final currentXpNotifier = ref.read(currentXpProvider.notifier);
    final correctGuessStreakNotifier = ref.read(correctGuessStreakProvider.notifier);
    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final currentHealthNotifier = ref.read(currentHealthProvider.notifier);

    currentScoreNotifier.update((state) => state + gainedScore);
    currentXpNotifier.update((state) {
      final newXp = state + gainedScore;
      if (newXp >= 10) {
        ref.read(gainItemProvider.notifier).update((state) => true);
        return newXp - 10;
      }
      return newXp;
    });
    correctGuessStreakNotifier.update((state) => state + 1);
    guessedPokemonNotifier.update((state) => []);
    currentHealthNotifier.update((state) => (state + 40).clamp(0, 100));

    ref.read(showGenerationHintProvider.notifier).update((state) => false);
    ref.read(showPokedexNumberHintProvider.notifier).update((state) => false);
    ref.read(correctGuessProvider.notifier).update((state) => true);
  }

  static void wrongGuess(WidgetRef ref) {
    final currentHealthNotifier = ref.read(currentHealthProvider.notifier);
    final currentHealth = (currentHealthNotifier.state - 20).clamp(0, 100);
    currentHealthNotifier.update((state) => currentHealth);

    if (currentHealth == 0) {
      ref.read(gameOverProvider.notifier).update((state) => true);
    }
  }

  static void resetSystem(WidgetRef ref) {
    final providers = [
      guessedPokemonListProvider,
      currentHealthProvider,
      currentXpProvider,
      currentScoreProvider,
      correctGuessStreakProvider,
      gameOverProvider,
      showGenerationHintProvider,
      showPokedexNumberHintProvider,
      gainItemProvider,
      correctGuessProvider,
      itemListProvider,
    ];

    for (var provider in providers) {
      ref.read(provider.notifier).update((state) {
        if (provider == guessedPokemonListProvider) return [];
        if (provider == currentHealthProvider) return 100;
        if (provider == currentXpProvider || provider == currentScoreProvider || provider == correctGuessStreakProvider) return 0;
        if (provider == gameOverProvider ||
            provider == showGenerationHintProvider ||
            provider == showPokedexNumberHintProvider ||
            provider == gainItemProvider ||
            provider == correctGuessProvider) return false;
        if (provider == itemListProvider) return [];
        return state;
      });
    }
  }
}
