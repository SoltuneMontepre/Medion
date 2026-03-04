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
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
      );
}

class AuthData {
  AuthData({required this.accessToken, required this.user});
  final String accessToken;
  final UserPayload user;
  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        accessToken: json['accessToken'] as String,
        user: UserPayload.fromJson(json['user'] as Map<String, dynamic>),
      );
}

/// Backend envelope: { "data": T, "message": string, "status": string, "code": int }
class AuthEnvelope {
  AuthEnvelope({required this.data, this.message, this.status});
  final AuthData data;
  final String? message;
  final String? status;
  factory AuthEnvelope.fromJson(Map<String, dynamic> json) => AuthEnvelope(
        data: AuthData.fromJson(json['data'] as Map<String, dynamic>),
        message: json['message'] as String?,
        status: json['status'] as String?,
      );
}
