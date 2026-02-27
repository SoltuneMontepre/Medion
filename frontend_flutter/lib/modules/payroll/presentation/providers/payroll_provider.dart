import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payroll_record.dart';
import '../../domain/usecases/get_payroll_records.dart';
import '../../data/repositories_impl/payroll_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final payrollRecordsProvider =
    FutureProvider.autoDispose.family<List<PayrollRecord>, int>((ref, page) {
  final repository = ref.watch(payrollRepositoryProvider);
  final useCase = GetPayrollRecords(repository);
  return useCase(page: page, pageSize: 20);
});
