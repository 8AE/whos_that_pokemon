import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/current_hp_bar.dart';
import 'package:whos_that_pokemon/widgets/current_xp_bar.dart';

class PokemonStatBox extends ConsumerWidget {
  const PokemonStatBox({super.key});

  static final _tierBoundry = {
    0: "Pokeball",
    10: "Great Ball",
    25: "Ultra Ball",
    40: "Master Ball",
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkmnGuessed = ref.watch(guessedPokemonListProvider);
    final score = ref.watch(currentScoreProvider);
    final correctGuessStreak = ref.watch(correctGuessStreakProvider);

    return SizedBox(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purpleAccent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Stats",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: "Guessing Tier: ", style: GoogleFonts.inter(fontWeight: FontWeight.normal)),
                      TextSpan(
                        text: _tierBoundry.entries.where((entry) => score >= entry.key).map((entry) => entry.value).last,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Score: $score",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Current Guesses: ${pkmnGuessed.length}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Correct Guess Streak: ${correctGuessStreak.toString()}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: CurrentHpBar(),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: CurrentXpBar(),
              ),
              const SizedBox(height: 5),
              // _giveupButton(),
            ],
          ),
        ),
      ),
    );
  }
}
