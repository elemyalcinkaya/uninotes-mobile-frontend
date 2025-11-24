class User {
  final int id;
  final String name;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  // Backend'den gelen JSON verisini modele çevirir
  factory User.fromJson(Map<String, dynamic> json) {
    // Backend yanıt formatı: { "message": "...", "token": "...", "user": { "id":... } }
    // Token ana objede, user detayları 'user' objesinin içinde.
    
    final userObj = json['user'];
    
    return User(
      id: userObj['id'],
      name: userObj['name'],
      email: userObj['email'],
      token: json['token'], // Token ana JSON objesinde
    );
  }
}