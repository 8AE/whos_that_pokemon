import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';

class PokemonStatTable extends ConsumerWidget {
  const PokemonStatTable({super.key});

  _statProgressBar(int statValue, Color barColor) {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: statValue / 255),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.transparent,
                color: barColor,
                minHeight: 10,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$statValue',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkmData = ref.watch(pokemonToGuessProvider);

    return Container(
      width: 400,
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
            Row(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HP: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Attack: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Defense: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Special Attack: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Special Defense: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Speed: ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _statProgressBar(pkmData!.hp, Colors.green),
                      _statProgressBar(pkmData.attack, Colors.yellow),
                      _statProgressBar(pkmData.defense, Colors.orange),
                      _statProgressBar(pkmData.specialAttack, Colors.cyan),
                      _statProgressBar(pkmData.specialDefense, Colors.blue),
                      _statProgressBar(pkmData.speed, Colors.purple),
                    ],
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(color: Colors.white),
                  children: [
                    const TextSpan(text: 'Total: '),
                    TextSpan(
                      text: '${pkmData.hp + pkmData.attack + pkmData.defense + pkmData.specialAttack + pkmData.specialDefense + pkmData.speed}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
