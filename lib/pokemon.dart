import 'dart:convert';

class Pokemon {
  final String name;
  final String type1;
  final String type2;
  final String spriteImageUrl;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final int id;

  Pokemon(
    this.name,
    this.type1,
    this.type2,
    this.spriteImageUrl,
    this.hp,
    this.attack,
    this.defense,
    this.specialAttack,
    this.specialDefense,
    this.speed,
    this.id,
  );

  factory Pokemon.fromHttpBody(String body) {
    var jsonData = jsonDecode(body);

    String name = jsonData['name'];
    String type1 = jsonData['types'][0]['type']['name'];
    String type2 = 'single_type';

    if (jsonData['types'].length > 1) {
      type2 = jsonData['types'][1]['type']['name'];
    }

    String spriteImageUrl = jsonData['sprites']['front_default'];

    //GOD I LOVE MAKING ASSUMPTIONS!
    int hp = jsonData['stats'][0]['base_stat'];
    int attack = jsonData['stats'][1]['base_stat'];
    int defense = jsonData['stats'][2]['base_stat'];
    int specialAttack = jsonData['stats'][3]['base_stat'];
    int specialDefense = jsonData['stats'][4]['base_stat'];
    int speed = jsonData['stats'][5]['base_stat'];
    int id = jsonData['id'];

    return Pokemon(name, type1, type2, spriteImageUrl, hp, attack, defense, specialAttack, specialDefense, speed, id);
  }

  @override
  String toString() {
    return 'Pokemon{name: $name, type1: $type1, type2: $type2, spriteImageUrl: $spriteImageUrl, hp: $hp, attack: $attack, defense: $defense, specialAttack: $specialAttack, specialDefense: $specialDefense, speed: $speed, id: $id}';
  }

  factory Pokemon.fromString(String body) {
    final parts = body.replaceAll('Pokemon{', '').replaceAll('}', '').split(', ');

    String name = parts[0].split(': ')[1];
    String type1 = parts[1].split(': ')[1];
    String type2 = parts[2].split(': ')[1];
    String spriteImageUrl = parts[3].split(': ')[1];
    int hp = int.parse(parts[4].split(': ')[1]);
    int attack = int.parse(parts[5].split(': ')[1]);
    int defense = int.parse(parts[6].split(': ')[1]);
    int specialAttack = int.parse(parts[7].split(': ')[1]);
    int specialDefense = int.parse(parts[8].split(': ')[1]);
    int speed = int.parse(parts[9].split(': ')[1]);
    int id = int.parse(parts[10].split(': ')[1]);

    return Pokemon(
      name,
      type1,
      type2,
      spriteImageUrl,
      hp,
      attack,
      defense,
      specialAttack,
      specialDefense,
      speed,
      id,
    );
  }
}
