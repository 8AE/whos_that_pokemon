import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';

class DailyCorrectGuess extends ConsumerWidget {
  const DailyCorrectGuess({super.key});

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
          child: Text('Share', style: GoogleFonts.inter(color: Colors.blue)),
          onPressed: () async {},
        ),
        TextButton(
          child: Text('Return to Main Menu', style: GoogleFonts.inter(color: Colors.white)),
          onPressed: () async {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
