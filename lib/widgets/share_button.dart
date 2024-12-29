import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whos_that_pokemon/daily/stat_compare.dart';
import 'package:whos_that_pokemon/pokemon/pokemon.dart';
import 'package:whos_that_pokemon/providers.dart';

class ShareButton extends ConsumerWidget {
  const ShareButton({super.key});

  String _guessingStat(WidgetRef ref, List<Pokemon> guessedPokemonList) {
    final pokemonToGuess = ref.read(pokemonToGuessProvider);
    String guesses = "";
    for (var pokemon in guessedPokemonList) {
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.hp, pokemonToGuess!.hp);
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.attack, pokemonToGuess.attack);
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.defense, pokemonToGuess.defense);
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.specialAttack, pokemonToGuess.specialAttack);
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.specialDefense, pokemonToGuess.specialDefense);
      guesses += StatCompare.symbolBasedOnStatDiff(pokemon.speed, pokemonToGuess.speed);
      final totalStatGuess = pokemon.hp + pokemon.attack + pokemon.defense + pokemon.specialAttack + pokemon.specialDefense + pokemon.speed;
      final totalStatToGuess = pokemonToGuess.hp +
          pokemonToGuess.attack +
          pokemonToGuess.defense +
          pokemonToGuess.specialAttack +
          pokemonToGuess.specialDefense +
          pokemonToGuess.speed;
      guesses += StatCompare.symbolBasedOnStatDiff(totalStatGuess, totalStatToGuess);
      guesses += "\n";
    }
    return guesses;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        final guessedPokemonList = ref.read(guessedPokemonListProvider);
        final shareText =
            "I guessed the Daily Pokémon in ${guessedPokemonList.length} tries! try now at https://8ae.github.io/whos_that_pokemon/ \n${_guessingStat(ref, guessedPokemonList)}";
        Share.share(shareText);
      },
      icon: const Icon(Icons.share),
      label: const Text("Share"),
    );
  }
}
