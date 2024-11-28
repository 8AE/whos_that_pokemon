import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:whos_that_pokemon/pokemon.dart';

class Pokedex extends StatefulWidget {
  Pokedex({super.key});

  @override
  State<Pokedex> createState() => _PokedexMainState();
}

class _PokedexMainState extends State<Pokedex> {
  List<Pokemon> pokemonList = [
    Pokemon('name', 'grass', 'fighting', "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/132.png", 100, 108, 109, 1, 2, 230, 132),
    Pokemon('name', 'grass', 'fighting', "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/133.png", 100, 108, 109, 1, 2, 230, 133)
  ];

  @override
  void initState() {
    super.initState();
  }

  _pokedexBox(Pokemon pokemon) {
    return Container(
      // width: 100,
      // height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.network(pokemon.spriteImageUrl),
          Text(pokemon.id.toString(), style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }

  _blankBox(int index) {
    final pokemon =
        Pokemon('name', 'grass', 'fighting', "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png", 100, 108, 109, 1, 2, 230, -1);
    return Container(
      // width: 100,
      // height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.network(pokemon.spriteImageUrl),
          Text(index.toString(), style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex', style: GoogleFonts.inter(color: Colors.white)),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        itemCount: 1026,
        itemBuilder: (context, index) {
          final pokemon = pokemonList.firstWhere(
            (pokemon) => pokemon.id == index + 1,
            orElse: () => Pokemon(
                'name', 'grass', 'fighting', "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png", 100, 108, 109, 1, 2, 230, -1),
          );
          if (pokemon.id != -1) {
            return _pokedexBox(pokemon);
          } else {
            return _blankBox(index + 1);
          }
        },
      ),
    );
  }
}
