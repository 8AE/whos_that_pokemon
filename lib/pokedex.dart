import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/pokemon.dart';
import 'package:sembast/sembast.dart';

class Pokedex extends StatefulWidget {
  final Database db;

  Pokedex({super.key, required this.db});

  @override
  State<Pokedex> createState() => _PokedexMainState();
}

class _PokedexMainState extends State<Pokedex> {
  List<Pokemon> pokemonList = [];

  @override
  void initState() {
    super.initState();

    var store = intMapStoreFactory.store('pokedex');

    List<Pokemon> newList = [];
    store.find(widget.db).then((records) {
      for (var record in records) {
        var pokemonData = record.value['pokemon'] as String;
        newList.add(Pokemon.fromString(pokemonData));
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          pokemonList = List.from(newList);
        });
      });
    });
  }

  _pokedexBox(Pokemon pokemon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.network(
            pokemon.spriteImageUrl,
            width: 90,
            height: 90,
          ),
          Text(pokemon.id.toString(), style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }

  _blankBox(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/no-pokemon.png',
            width: 90,
            height: 90,
          ),
          Text(index.toString(), style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: GoogleFonts.inter(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        itemCount: 1025,
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
