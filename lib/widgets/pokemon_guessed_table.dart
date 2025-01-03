import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/daily/stat_compare.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/widgets/pokemon_type.dart';

class PokemonGuessedTable extends ConsumerWidget {
  const PokemonGuessedTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guessedPokemonList = ref.watch(guessedPokemonListProvider);
    final pokemonToGuess = ref.watch(pokemonToGuessProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Sprite', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Name', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Type', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('HP', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Attack', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Defense', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Sp. Atk', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Sp. Def', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Speed', style: GoogleFonts.inter(color: Colors.white))),
          DataColumn(label: Text('Total', style: GoogleFonts.inter(color: Colors.white))),
        ],
        rows: guessedPokemonList.map((pokemon) {
          return DataRow(cells: [
            DataCell(
              Image.network(
                pokemon.isShiny ? pokemon.shinySpriteImageUrl : pokemon.spriteImageUrl,
                height: 100,
                width: 50,
              ),
            ),
            DataCell(Text(pokemon.name, style: GoogleFonts.inter(color: Colors.white))),
            DataCell(PokemonType(pokemon.type1, pokemon.type2)),
            DataCell(Text(pokemon.hp.toString(), style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.hp, pokemonToGuess!.hp)))),
            DataCell(
                Text(pokemon.attack.toString(), style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.attack, pokemonToGuess.attack)))),
            DataCell(
                Text(pokemon.defense.toString(), style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.defense, pokemonToGuess.defense)))),
            DataCell(Text(pokemon.specialAttack.toString(),
                style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.specialAttack, pokemonToGuess.specialAttack)))),
            DataCell(Text(pokemon.specialDefense.toString(),
                style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.specialDefense, pokemonToGuess.specialDefense)))),
            DataCell(Text(pokemon.speed.toString(), style: GoogleFonts.inter(color: StatCompare.colorsBasedOnStatDiff(pokemon.speed, pokemonToGuess.speed)))),
            DataCell(
              Text((pokemon.hp + pokemon.attack + pokemon.defense + pokemon.specialAttack + pokemon.specialDefense + pokemon.speed).toString(),
                  style: GoogleFonts.inter(
                      color: StatCompare.colorsBasedOnStatDiff(
                          pokemon.hp + pokemon.attack + pokemon.defense + pokemon.specialAttack + pokemon.specialDefense + pokemon.speed,
                          pokemonToGuess.hp +
                              pokemonToGuess.attack +
                              pokemonToGuess.defense +
                              pokemonToGuess.specialAttack +
                              pokemonToGuess.specialDefense +
                              pokemonToGuess.speed))),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
