class Sheep {
  final int? id;
  final String idBoucle;
  final String race;
  final String sexe;
  final int age;
  final String couleur;
  final int flockId;
  
  Sheep({
    this.id,
    required this.idBoucle,
    required this.race,
    required this.sexe,
    required this.age,
    required this.couleur,
    required this.flockId,
  });
  
  factory Sheep.fromJson(Map<String, dynamic> json) {
    return Sheep(
      id: json['id'],
      idBoucle: json['idBoucle'],
      race: json['race'],
      sexe: json['sexe'],
      age: json['age'],
      couleur: json['couleur'],
      flockId: json['flock_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idBoucle': idBoucle,
      'race': race,
      'sexe': sexe,
      'age': age,
      'couleur': couleur,
      'flock_id': flockId,
    };
  }
}

