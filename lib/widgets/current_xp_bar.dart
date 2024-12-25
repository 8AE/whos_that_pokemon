import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';

class CurrentXpBar extends ConsumerWidget {
  const CurrentXpBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentXp = ref.watch(currentXpProvider);

    return Row(
      children: [
        Text(
          'XP: ',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: currentXp / 10),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey,
                color: Colors.blue,
                minHeight: 10,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$currentXp/10',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
