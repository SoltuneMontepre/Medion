import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/customers_repository_impl.dart';
import '../../domain/entities/customer_list_result.dart';
import '../../domain/usecases/get_customers.dart';

final customersProvider =
    FutureProvider.autoDispose.family<CustomerListResult, int>((ref, page) {
  final repository = ref.watch(customersRepositoryProvider);
  final useCase = GetCustomers(repository);
  return useCase(page: page, pageSize: 20);
});
