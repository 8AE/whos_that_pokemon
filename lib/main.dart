import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/screens/home_screen.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  var factory = databaseFactoryWeb;

  // Open the database in web cache
  Database db = await factory.openDatabase('pokemon_db');
  runApp(ProviderScope(child: MyApp(db: db)));
}

class MyApp extends StatelessWidget {
  final Database db;
  const MyApp({super.key, required this.db});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Who's That Pokemon",
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple)),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: SafeArea(child: HomeScreen(db: db)),
    );
  }
}
