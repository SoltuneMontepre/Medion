/// Request/response DTOs matching backend API (auth controller).

class LoginRequest {
  LoginRequest({required this.email, required this.password});
  final String email;
  final String password;
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class UserPayload {
  UserPayload({
    required this.id,
    required this.username,
    required this.email,
  });
  final String id;
  final String username;
  final String email;
  factory UserPayload.fromJson(Map<String, dynamic> json) => UserPayload(
        id: _stringFromJson(json['id'])!,
        username: _stringFromJson(json['username'])!,
        email: _stringFromJson(json['email'])!,
      );
}

String? _stringFromJson(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

class AuthData {
  AuthData({required this.accessToken, required this.user});
  final String accessToken;
  final UserPayload user;
  factory AuthData.fromJson(Map<String, dynamic> json) {
    final userMap = _mapFromJson(json['user']);
    if (userMap == null) throw FormatException('Missing or invalid "user" in login response', json.toString());
    return AuthData(
      accessToken: _stringFromJson(json['accessToken']) ?? '',
      user: UserPayload.fromJson(userMap),
    );
  }
}

/// Backend envelope: { "data": T, "message": string, "status": string, "code": int }
class AuthEnvelope {
  AuthEnvelope({required this.data, this.message, this.status});
  final AuthData data;
  final String? message;
  final String? status;
  factory AuthEnvelope.fromJson(Map<String, dynamic> json) {
    final dataMap = _mapFromJson(json['data']);
    if (dataMap == null) throw FormatException('Missing or invalid "data" in login response', json.toString());
    return AuthEnvelope(
      data: AuthData.fromJson(dataMap),
      message: json['message'] as String?,
      status: json['status'] as String?,
    );
  }
}

Map<String, dynamic>? _mapFromJson(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  return null;
}
