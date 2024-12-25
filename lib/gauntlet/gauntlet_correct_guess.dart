import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/providers.dart';

class GauntletCorrectGuess extends ConsumerWidget {
  const GauntletCorrectGuess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    return AlertDialog(
      title: Text('Congrats!!!', style: GoogleFonts.inter(color: Colors.green)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Good job you guessed it right.', style: GoogleFonts.inter(color: Colors.white)),
            Image.network(
              pokemonToGuess!.isShiny ? pokemonToGuess.shinySpriteImageUrl : pokemonToGuess.spriteImageUrl,
              width: 100,
              height: 100,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Next Pokemon', style: GoogleFonts.inter(color: Colors.purpleAccent)),
          onPressed: () async {
            await PokemonGenerator.generatePokemon(ref);
            ref.read(correctGuessProvider.notifier).update((state) => false);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
