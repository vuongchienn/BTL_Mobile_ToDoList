import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required int id,
    required String email,
    String? name,
  }) : super(id: id, email: email, name: name);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      name: json['name'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  User toEntity() => User(id: id, email: email, name: name);
}