import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Who's That Pokemon",
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple)),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: SafeArea(child: HomeScreen()),
    );
  }
}
