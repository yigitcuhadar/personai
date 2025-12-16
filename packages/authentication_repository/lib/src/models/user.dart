import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.name, required this.email, required this.photo});

  final String id;
  final String? name;
  final String? email;
  final String? photo;

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'] ?? "", name: json['name'] ?? "", email: json['email'] ?? "", photo: json['imageUrl'] ?? "");

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name, 'email': email, 'imageUrl': photo};
  @override
  List<Object?> get props => [id, name, email, photo];
}
