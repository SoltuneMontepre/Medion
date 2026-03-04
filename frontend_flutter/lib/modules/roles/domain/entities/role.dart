/// Domain entity for a role (with optional parent for hierarchy).
class Role {
  const Role({
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
}

/// Params for create/update role.
class RoleMutationParams {
  const RoleMutationParams({
    required this.code,
    required this.name,
    this.description = '',
    this.parentRoleId,
  });
  final String code;
  final String name;
  final String description;
  final String? parentRoleId;
}
