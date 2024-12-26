import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/items/item_manager.dart';
import 'package:whos_that_pokemon/providers.dart';

class ItemBag extends ConsumerStatefulWidget {
  const ItemBag({super.key});

  @override
  _ItemBagState createState() => _ItemBagState();
}

class _ItemBagState extends ConsumerState<ItemBag> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemListProvider);

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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Bag",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(
                      items[index].imageAssetPath,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      items[index].name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        ItemManager.useItem(ref, items[index]);
                      });
                    },
                  );
                },
              ),
              if (items.isEmpty)
                Text(
                  "No items",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
