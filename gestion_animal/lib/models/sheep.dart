class Sheep {
  final String idBoucle;
  final String race;
  final String sexe;
  final int age;
  final String couleur;
  final int flockId;
  Sheep({
    required this.idBoucle,
    required this.race,
    required this.sexe,
    required this.age,
    required this.couleur,
    required this.flockId,
  });
  factory Sheep.fromJson(Map json) {
    return Sheep(
      idBoucle: json['idBoucle'],
      race: json['race'],
      sexe: json['sexe'],
      age: json['age'],
      couleur: json['couleur'],
      flockId: json['flock_id'],
    );
  }
  Map toJson() {
    return {
      'idBoucle': idBoucle,
      'race': race,
      'sexe': sexe,
      'age': age,
      'couleur': couleur,
      'flock_id': flockId,
    };
  }
}