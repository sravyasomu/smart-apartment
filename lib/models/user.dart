class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String apartmentNumber;
  final String block;
  final String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.apartmentNumber,
    required this.block,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'apartmentNumber': apartmentNumber,
      'block': block,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      apartmentNumber:
          map['apartmentNumber'] ?? '',
      block: map['block'] ?? '',
      password: map['password'] ?? '',
    );
  }
}