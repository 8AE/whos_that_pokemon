import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';
import 'dart:math';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreen> {
  List<List<bool>> isSelectedBoolList = List.generate(9, (_) => [true]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text(
            "Who's that pokemon",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("Generation Filters", textAlign: TextAlign.center),
          ),
          GridView.count(
            // crossAxisSpacing: 1,
            crossAxisCount: 3,
            shrinkWrap: true,
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
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WhosThatPokemon(),
                  ),
                );
              },
              child: const Text("Start Game"))
        ],
      ),
    );
  }
}
