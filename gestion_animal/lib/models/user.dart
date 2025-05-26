class User {
  final int? id;
  final String name;
  final String email;
  User({
    this.id,
    required this.name,
    required this.email,
  });
  factory User.fromJson(Map json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  Map toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
class UserCreate {
  final String name;
  final String email;
  final String password;
  UserCreate({
    required this.name,
    required this.email,
    required this.password,
  });
  Map toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}