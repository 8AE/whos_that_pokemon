import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';

class GenerationSelector extends StatefulWidget {
  final Map<String, bool> generationMap;

  GenerationSelector({super.key, required this.generationMap});

  @override
  State<GenerationSelector> createState() => GenerationSelectorMainState();
}

class GenerationSelectorMainState extends State<GenerationSelector> {
  late Map<String, bool> newGenerationMap;

  final Map<String, String> generationLabels = {
    "gen1": "Generation 1",
    "gen2": "Generation 2",
    "gen3": "Generation 3",
    "gen4": "Generation 4",
    "gen5": "Generation 5",
    "gen6": "Generation 6",
    "gen7": "Generation 7",
    "gen8": "Generation 8",
    "gen9": "Generation 9",
  };

  @override
  void initState() {
    super.initState();
    newGenerationMap = Map.from(widget.generationMap);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _selectionHasChanged() {
    return !newGenerationMap.entries.every((element) => element.value == widget.generationMap[element.key]);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning', style: GoogleFonts.inter(color: Colors.red)),
          content: Text('Changing generations will break your current streak.', style: GoogleFonts.inter(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Change Generations', style: GoogleFonts.inter(color: Colors.purpleAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => WhosThatPokemon(newGenerationMap, 0),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  _submitButton() {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _selectionHasChanged() ? Colors.purpleAccent : Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: () {
          if (_selectionHasChanged()) {
            _showMyDialog();
          }
        },
        child: Text("Submit", style: GoogleFonts.inter(color: _selectionHasChanged() ? Colors.white : Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "Generations Filters",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ListView(
                  shrinkWrap: true,
                  children: widget.generationMap.keys.map((generation) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: widget.generationMap.keys.first == generation ? 1.0 : 0.7,
                          ),
                          left: BorderSide(color: Colors.grey, width: 1.0),
                          right: BorderSide(color: Colors.grey, width: 1.0),
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: widget.generationMap.keys.last == generation ? 1.0 : 0.7,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          generationLabels[generation]!,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        selected: newGenerationMap[generation]!,
                        selectedTileColor: Colors.purpleAccent.withOpacity(0.5),
                        onTap: () {
                          setState(() {
                            newGenerationMap[generation] = !newGenerationMap[generation]!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                _submitButton(),
              ],
            )),
      ),
    );
  }
}
