import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';
import 'dart:math';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreen> {
  final VideoPlayerController _controller = VideoPlayerController.asset("assets/video/background.mp4");
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      _controller.setLooping(true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _controller.play();
          _visible = true;
        });
      });
    });
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

  _getVideoBackground() {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 1000),
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size?.width ?? 0,
                height: _controller.value.size?.height ?? 0,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _getVideoBackground(),
          Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: ListView(
                children: [
                  const Text(
                    "Who's That Pokemon",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AntipastoPro',
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                  ),
                  ElevatedButton(
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
                      child: const Text("Start Game"))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
