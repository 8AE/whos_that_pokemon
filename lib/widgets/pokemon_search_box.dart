import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';

class PokemonSearchBox extends ConsumerWidget {
  final Function(String) guessPokemonFunction;

  const PokemonSearchBox({required this.guessPokemonFunction, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkmNameList = ref.watch(pokemonNameListProvider);

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          ref.read(guessingBoxIsFocusedProvider.notifier).update((state) => true);
        } else {
          ref.read(guessingBoxIsFocusedProvider.notifier).update((state) => false);
        }
      },
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return pkmNameList.where((String name) {
            return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: guessPokemonFunction,
        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelStyle: GoogleFonts.inter(color: Colors.white),
              labelText: 'Search Pokémon',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.purpleAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.purpleAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.purpleAccent),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
            ),
            onSubmitted: (value) {
              onFieldSubmitted();
              textEditingController.clear();
            },
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
          final indexToHighlight = AutocompleteHighlightedOption.of(context);

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
                  LogicalKeySet(LogicalKeyboardKey.arrowDown): const AutocompleteNextOptionIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp): const AutocompletePreviousOptionIntent(),
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bool isHighlighted = index == indexToHighlight;
                    return GestureDetector(
                      onTap: () {
                        onSelected(options.elementAt(index));
                      },
                      child: Container(
                        color: isHighlighted ? Colors.purpleAccent.withOpacity(0.5) : null,
                        child: ListTile(
                          title: Text(
                            options.elementAt(index),
                            style: TextStyle(
                              color: isHighlighted ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
