import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/providers.dart';

class GauntletWrongGuess extends ConsumerWidget {
  const GauntletWrongGuess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    return AlertDialog(
      title: Text('White Out', style: GoogleFonts.inter(color: Colors.red)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Game Over! \nYour HP has dropped to 0, resetting your correct guess streak.', style: GoogleFonts.inter(color: Colors.white)),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'The Pokémon you were trying to guess was ',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  TextSpan(
                    text: pokemonToGuess!.name,
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '.',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ],
              ),
            ),
            Image.network(
              pokemonToGuess.isShiny ? pokemonToGuess.shinySpriteImageUrl : pokemonToGuess.spriteImageUrl,
              width: 100,
              height: 100,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Return to Main menu', style: GoogleFonts.inter(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Retry', style: GoogleFonts.inter(color: Colors.purpleAccent)),
          onPressed: () async {
            await PokemonGenerator.generatePokemon(ref);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
