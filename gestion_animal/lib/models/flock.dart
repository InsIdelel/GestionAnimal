class Flock {
  final int? id;
  final String nom;
  final int userId;
  Flock({
    this.id,
    required this.nom,
    required this.userId,
  });
  factory Flock.fromJson(Map json) {
    return Flock(
      id: json['id'],
      nom: json['nom'],
      userId: json['user_id'],
    );
  }
  Map toJson() {
    return {
      'id': id,
      'nom': nom,
      'user_id': userId,
    };
  }
}