import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:whos_that_pokemon/daily/daily_system.dart';
import 'package:whos_that_pokemon/game_mode/game_mode.dart';
import 'package:whos_that_pokemon/pokemon/pokemon_generator.dart';
import 'package:whos_that_pokemon/screens/change_log_screen.dart';
import 'package:whos_that_pokemon/screens/pokedex.dart';
import 'package:whos_that_pokemon/screens/game_screen.dart';
import 'package:sembast/sembast.dart';

class HomeScreen extends ConsumerWidget {
  final Database db;

  HomeScreen({super.key, required this.db});

  Future<void> _showMyDialog(BuildContext context) async {
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

  _gauntletButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purpleAccent),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          DailySystem.resetSystem(ref);
          await PokemonGenerator.generatePokemon(ref);

          Navigator.of(context).pop(); // Close the loading dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameScreen(db: db, gameMode: GameMode.gauntlet),
            ),
          );
        },
        child: Text("Gauntlet", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _dailyButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purpleAccent),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          DailySystem.resetSystem(ref);
          await PokemonGenerator.generateDailyPokemon(ref);

          Navigator.of(context).pop(); // Close the loading dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameScreen(db: db, gameMode: GameMode.daily),
            ),
          );
        },
        child: Text("Daily", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _onlineButton() {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
        ),
        onPressed: null,
        child: Text("Online", style: GoogleFonts.inter(color: Colors.grey)),
      ),
    );
  }

  _pokedexButton(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purpleAccent),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Pokedex(db: db),
            ),
          );
        },
        child: Text("Pokédex", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _changelogButton(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purpleAccent),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeLogScreen(),
            ),
          );
        },
        child: Text("Change Log", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Text(
                              'Version: ${snapshot.data!.version}',
                              style: GoogleFonts.inter(color: Colors.white),
                            );
                          } else {
                            return Text(
                              'Failed to get version',
                              style: GoogleFonts.inter(color: Colors.white),
                            );
                          }
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _dailyButton(context, ref),
                    const SizedBox(height: 10),
                    _gauntletButton(context, ref),
                    Visibility(
                      visible: false,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _onlineButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(
                      width: 200,
                      child: Divider(
                        color: Colors.purpleAccent,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _pokedexButton(context),
                    const SizedBox(
                      height: 10,
                    ),
                    _changelogButton(context),
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
