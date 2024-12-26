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
    var currentScore = currentScoreNotifier.state;

    currentScore += gainedScore;

    final currentXpNotifier = ref.read(currentXpProvider.notifier);
    var currentXp = currentXpNotifier.state;
    currentXp = (currentXp + gainedScore);

    if (currentXp >= 10) {
      currentXp = currentXp - 10;
      ref.read(gainItemProvider.notifier).update((state) => true);
    }

    currentXpNotifier.update((state) => currentXp);
    currentScoreNotifier.update((state) => currentScore);

    final correctGuessStreakNotifier = ref.read(correctGuessStreakProvider.notifier);
    var correctGuessStreak = correctGuessStreakNotifier.state;

    correctGuessStreak += 1;
    correctGuessStreakNotifier.update((state) => correctGuessStreak);

    final guessedPokemonNotifier = ref.read(guessedPokemonListProvider.notifier);
    final guessedPokemon = guessedPokemonNotifier.state;

    guessedPokemon.clear();
    guessedPokemonNotifier.update((state) => guessedPokemon);

    final currentHealthNotifier = ref.read(currentHealthProvider.notifier);
    var currentHealth = currentHealthNotifier.state;

    currentHealth = (currentHealth + 40).clamp(0, 100);
    currentHealthNotifier.update((state) => currentHealth);

    ref.read(showGenerationHintProvider.notifier).update((state) => false);
    ref.read(showPokedexNumberHintProvider.notifier).update((state) => false);

    ref.read(correctGuessProvider.notifier).update((state) => true);
  }

  static void wrongGuess(WidgetRef ref) {
    final currentHealthNotifier = ref.read(currentHealthProvider.notifier);
    var currentHealth = currentHealthNotifier.state;

    currentHealth = (currentHealth - 20).clamp(0, 100);
    currentHealthNotifier.update((state) => currentHealth);

    if (currentHealth == 0) {
      final gameOverNotifier = ref.read(gameOverProvider.notifier);
      gameOverNotifier.update((state) => true);
    }
  }

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
