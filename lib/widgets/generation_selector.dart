import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';
import 'package:whos_that_pokemon/whos_that_pokemon.dart';
import 'package:sembast/sembast.dart';

class GenerationSelector extends ConsumerStatefulWidget {
  const GenerationSelector({super.key});

  @override
  ConsumerState<GenerationSelector> createState() => GenerationSelectorMainState();
}

class GenerationSelectorMainState extends ConsumerState<GenerationSelector> {
  late Map<String, bool> newGenerationMap;
  late Map<String, bool> currentGenerationMap;

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

    currentGenerationMap = ref.read(generationMapProvider.notifier).state;
    newGenerationMap = Map.from(currentGenerationMap);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _selectionHasChanged() {
    return !newGenerationMap.entries.every((element) => element.value == currentGenerationMap[element.key]);
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
                ref.read(generationMapProvider.notifier).update((state) => newGenerationMap);
                Navigator.of(context).pop();
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
          if (newGenerationMap.values.every((isSelected) => !isSelected)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('At least one generation must be selected.', style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

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
    currentGenerationMap = ref.watch(generationMapProvider);

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
                  physics: NeverScrollableScrollPhysics(),
                  children: currentGenerationMap.keys.map((generation) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: currentGenerationMap.keys.first == generation ? 1.0 : 0.7,
                          ),
                          left: BorderSide(color: Colors.grey, width: 1.0),
                          right: BorderSide(color: Colors.grey, width: 1.0),
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: currentGenerationMap.keys.last == generation ? 1.0 : 0.7,
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
