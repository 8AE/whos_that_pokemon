import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<List<bool>> isSelectedBoolList = List.generate(9, (_) => [true]);
  Map<String, bool> generationMap = {
    "gen1": true,
    "gen2": true,
    "gen3": true,
    "gen4": true,
    "gen5": true,
    "gen6": true,
    "gen7": true,
    "gen8": true,
    "gen9": true,
  };

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please Select at least one Generation to play the game.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _generationFilter() {
    return [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text("Generation Filters", textAlign: TextAlign.center),
      ),
      SizedBox(
        width: 500,
        height: 500,
        child: GridView.count(
          // crossAxisSpacing: 1,
          crossAxisCount: 3,
          shrinkWrap: false,
          children: [
            for (var i = 0; i < 9; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Container(
                    width: 150,
                    height: 80,
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (int index) {
                        setState(() {
                          isSelectedBoolList[i][index] = !isSelectedBoolList[i][index];
                          generationMap['gen${i + 1}'] = isSelectedBoolList[i][index];
                        });
                      },
                      isSelected: isSelectedBoolList[i],
                      children: [
                        Text("Generation ${i + 1}"),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: "Who's That "),
                          TextSpan(
                            text: "Pokémon",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purpleAccent),
                        ),
                        onPressed: () {
                          if (generationMap.values.every((element) => element == false)) {
                            _showMyDialog();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WhosThatPokemon(generationMap),
                              ),
                            );
                          }
                        },
                        child: Text("Daily", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purpleAccent),
                        ),
                        onPressed: () {
                          if (generationMap.values.every((element) => element == false)) {
                            _showMyDialog();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WhosThatPokemon(generationMap),
                              ),
                            );
                          }
                        },
                        child: Text("Infinite", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purpleAccent),
                        ),
                        onPressed: () {
                          if (generationMap.values.every((element) => element == false)) {
                            _showMyDialog();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WhosThatPokemon(generationMap),
                              ),
                            );
                          }
                        },
                        child: Text("Online", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
