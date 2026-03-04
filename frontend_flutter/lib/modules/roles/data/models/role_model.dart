import '../../domain/entities/role.dart';

class RoleModel {
  const RoleModel({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    this.parentRoleId,
    this.parentCode,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String? parentRoleId;
  final String? parentCode;

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final pid = json['parentRoleId'];
    return RoleModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      parentRoleId: pid != null ? pid.toString() : null,
      parentCode: json['parentCode'] as String?,
    );
  }

  Role toEntity() => Role(
        id: id,
        code: code,
        name: name,
        description: description,
        parentRoleId: parentRoleId,
        parentCode: parentCode,
      );
}
