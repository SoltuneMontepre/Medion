import '../../domain/entities/security_info.dart';

/// Data model with fromJson. Maps to domain entity.
class SecurityInfoModel {
  const SecurityInfoModel({
    required this.userId,
    required this.transactionPinSet,
    required this.lastLogin,
  });

  final String userId;
  final bool transactionPinSet;
  final String lastLogin;

  factory SecurityInfoModel.fromJson(Map<String, dynamic> json) {
    return SecurityInfoModel(
      userId: json['userId'] as String? ?? '',
      transactionPinSet: json['transactionPinSet'] as bool? ?? false,
      lastLogin: json['lastLogin'] as String? ?? '',
    );
  }

  SecurityInfo toEntity() => SecurityInfo(
        userId: userId,
        transactionPinSet: transactionPinSet,
        lastLogin: lastLogin,
      );
}
