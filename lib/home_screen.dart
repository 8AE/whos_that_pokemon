import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:whos_that_pokemon/change_log_screen.dart';
import 'package:whos_that_pokemon/pokedex.dart';
import 'package:whos_that_pokemon/screens/game_screen.dart';
import 'package:sembast/sembast.dart';

class HomeScreen extends StatefulWidget {
  final Database db;

  HomeScreen({super.key, required this.db});

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

  _gauntletButton() {
    return SizedBox(
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
                builder: (context) => GameScreen(widget.db),
              ),
            );
          }
        },
        child: Text("Gauntlet", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _dailyButton() {
    return SizedBox(
      width: 200,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
        ),
        onPressed: null,
        child: Text("Daily", style: GoogleFonts.inter(color: Colors.grey)),
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

  _pokedexButton() {
    return SizedBox(
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
                builder: (context) => Pokedex(db: widget.db),
              ),
            );
          }
        },
        child: Text("Pokédex", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  _changelogButton() {
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
                    _dailyButton(),
                    const SizedBox(height: 10),
                    _gauntletButton(),
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
                    _pokedexButton(),
                    const SizedBox(
                      height: 10,
                    ),
                    _changelogButton(),
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
