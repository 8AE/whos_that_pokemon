import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/items/item_manager.dart';

class GauntLetGetItem extends ConsumerWidget {
  const GauntLetGetItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Level Up! New Item Earned', style: GoogleFonts.inter(color: Colors.purpleAccent)),
      content: SingleChildScrollView(
        child: ListBody(
          children: ItemManager.getItems(3).map((item) {
            return ListTile(
              leading: Image.asset(item.imageAssetPath, width: 50, height: 50),
              title: Text(item.name, style: GoogleFonts.inter(color: Colors.white)),
              subtitle: Text(item.description, style: GoogleFonts.inter(color: Colors.white)),
              onTap: () {
                ItemManager.addItem(ref, item);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
