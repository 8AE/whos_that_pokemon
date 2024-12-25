import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/pokemon_stat_table.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';

class PokemonInfo extends ConsumerWidget {
  const PokemonInfo({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    return Column(
      children: [
        const PokemonStatTable(),
        const SizedBox(height: 5),
        PokemonType(pokemonToGuess!.type1, pokemonToGuess!.type2),
        // const SizedBox(height: 5),
        // Visibility(
        //   visible: _showGen,
        //   child: Text(
        //     pokemonSpecies!.generation.replaceAll('-', ' '),
        //     style: GoogleFonts.inter(
        //       fontSize: 16,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 5),
        // Visibility(
        //   visible: _showPokedexNumber,
        //   child: Text(
        //     'Pokedex Number: ${pokemonSpecies!.id}',
        //     style: GoogleFonts.inter(
        //       fontSize: 16,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
