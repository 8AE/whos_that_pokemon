import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whos_that_pokemon/widgets/generation_selector.dart';
import 'package:whos_that_pokemon/providers.dart';

void main() {
  // testWidgets('GenerationSelector displays correctly', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     ProviderScope(
  //       child: MaterialApp(
  //         home: Scaffold(
  //           body: GenerationSelector(),
  //         ),
  //       ),
  //     ),
  //   );

  //   expect(find.text('Generations Filters'), findsOneWidget);
  //   expect(find.text('Generation 1'), findsOneWidget);
  //   expect(find.text('Generation 2'), findsOneWidget);
  //   expect(find.text('Generation 3'), findsOneWidget);
  //   expect(find.text('Generation 4'), findsOneWidget);
  //   expect(find.text('Generation 5'), findsOneWidget);
  //   expect(find.text('Generation 6'), findsOneWidget);
  //   expect(find.text('Generation 7'), findsOneWidget);
  //   expect(find.text('Generation 8'), findsOneWidget);
  //   expect(find.text('Generation 9'), findsOneWidget);
  // });

  // testWidgets('Tapping on a generation toggles selection', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     ProviderScope(
  //       child: MaterialApp(
  //         home: Scaffold(
  //           body: GenerationSelector(),
  //         ),
  //       ),
  //     ),
  //   );

  //   await tester.tap(find.text('Generation 1'));
  //   await tester.pump();

  //   expect(find.byType(ListTile).first, findsOneWidget);
  //   expect((tester.widget(find.byType(ListTile).first) as ListTile).selected, isTrue);
  // });

  // testWidgets('Submit button shows warning dialog if selection changed', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     const ProviderScope(
  //       child: MaterialApp(
  //         home: Scaffold(
  //           body: SingleChildScrollView(
  //             child: Column(children: [GenerationSelector()]),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   await tester.tap(find.text('Generation 1'));
  //   await tester.pump();

  //   await tester.tap(find.text('Submit'));
  //   await tester.pump();

  //   expect(find.text('Warning'), findsOneWidget);
  //   expect(find.text('Changing generations will break your current streak.'), findsOneWidget);
  // });

  // testWidgets('Submit button shows snackbar if no generation is selected', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     const ProviderScope(
  //       child: MaterialApp(
  //         home: Scaffold(
  //           body: SingleChildScrollView(
  //             child: Column(children: [GenerationSelector()]),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   await tester.tap(find.text('Generation 1'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 2'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 3'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 4'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 5'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 6'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 7'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 8'));
  //   await tester.pump();
  //   await tester.tap(find.text('Generation 9'));
  //   await tester.pump();

  //   await tester.tap(find.text('Submit'));
  //   await tester.pump();

  //   // expect(find.text('At least one generation must be selected.'), findsOneWidget);
  // });
}
