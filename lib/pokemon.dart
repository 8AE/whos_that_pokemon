import 'dart:math';
import 'dart:convert';

class Pokemon {
  late final String name;
  late final String type1;
  late final String type2;
  late final String spriteImageUrl;
  late final int hp;
  late final int attack;
  late final int defense;
  late final int specialAttack;
  late final int specialDefense;
  late final int speed;

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
    );
  }
}
