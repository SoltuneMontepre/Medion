import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/security_info.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_remote_datasource.dart';
import '../datasources/security_remote_datasource_impl.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._dataSource);

  final SecurityRemoteDataSource _dataSource;

  @override
  Future<SecurityInfo> getSecurityInfo() async {
    final model = await _dataSource.fetchSecurityInfo();
    return model.toEntity();
  }
}

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  final dataSource = ref.watch(securityRemoteDataSourceProvider);
  return SecurityRepositoryImpl(dataSource);
});
