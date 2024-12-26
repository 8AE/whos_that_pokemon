import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whos_that_pokemon/providers.dart';

class CurrentHpBar extends ConsumerWidget {
  const CurrentHpBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHealth = ref.watch(currentHealthProvider);

    return Row(
      children: [
        Text(
          'HP: ',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: currentHealth / 100),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey,
                color: currentHealth <= 20 ? Colors.red : Colors.green,
                minHeight: 10,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$currentHealth/100',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
