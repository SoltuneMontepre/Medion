import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/security_info.dart';
import '../../domain/usecases/get_security_info.dart';
import '../../data/repositories_impl/security_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final securityInfoProvider = FutureProvider.autoDispose<SecurityInfo>((ref) {
  final repository = ref.watch(securityRepositoryProvider);
  final useCase = GetSecurityInfo(repository);
  return useCase();
});
