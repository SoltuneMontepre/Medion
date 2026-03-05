import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/production_order.dart';
import '../../domain/repositories/production_repository.dart';
import '../datasources/production_remote_datasource.dart';
import '../datasources/production_remote_datasource_impl.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  ProductionRepositoryImpl(this._dataSource);

  final ProductionRemoteDataSource _dataSource;

  @override
  Future<List<ProductionOrder>> getOrders({int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final models = await _dataSource.fetchOrders(limit: pageSize, offset: offset);
    return models.map((m) => m.toEntity()).toList();
  }
}

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final dataSource = ref.watch(productionRemoteDataSourceProvider);
  return ProductionRepositoryImpl(dataSource);
});
