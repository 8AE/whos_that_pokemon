import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';

class GenerationSelector extends StatefulWidget {
  GenerationSelector({super.key});

  @override
  State<GenerationSelector> createState() => GenerationSelectorMainState();
}

class GenerationSelectorMainState extends State<GenerationSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purpleAccent,
            width: 2.0,
          ),
        ),
        child: Text(
          'Guess the Pokémon!',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
