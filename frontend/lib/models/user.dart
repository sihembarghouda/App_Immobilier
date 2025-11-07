class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}