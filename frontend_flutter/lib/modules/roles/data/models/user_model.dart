import '../../domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.supervisorId,
    this.supervisor,
  });

  final String id;
  final String username;
  final String email;
  final String? supervisorId;
  final UserModel? supervisor;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final sup = json['supervisor'];
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      supervisorId: json['supervisorId']?.toString(),
      supervisor: sup is Map<String, dynamic>
          ? UserModel.fromJson(sup)
          : null,
    );
  }

  User toEntity() => User(
        id: id,
        username: username,
        email: email,
        supervisorId: supervisorId,
        supervisorUsername: supervisor?.username,
      );
}
