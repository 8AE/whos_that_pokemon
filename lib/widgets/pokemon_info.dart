import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/pokemon_stat_table.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';

class PokemonInfo extends ConsumerWidget {
  const PokemonInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);
    final pokemonSpecies = ref.watch(pokemonSpeciesProvider);
    final showGen = ref.watch(showGenerationHintProvider);
    final showPokedexNumber = ref.watch(showPokedexNumberHintProvider);

    return Column(
      children: [
        const PokemonStatTable(),
        const SizedBox(height: 5),
        PokemonType(pokemonToGuess!.type1, pokemonToGuess!.type2),
        const SizedBox(height: 5),
        Visibility(
          visible: showGen,
          child: Text(
            pokemonSpecies!.generation.replaceAll('-', ' '),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Visibility(
          visible: showPokedexNumber,
          child: Text(
            'Pokedex Number: ${pokemonSpecies.id}',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
