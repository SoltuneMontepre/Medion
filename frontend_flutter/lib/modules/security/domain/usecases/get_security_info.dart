import '../entities/security_info.dart';
import '../repositories/security_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetSecurityInfo {
  GetSecurityInfo(this._repository);

  final SecurityRepository _repository;

  Future<SecurityInfo> call() => _repository.getSecurityInfo();
}
