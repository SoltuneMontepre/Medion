import '../entities/customer.dart';
import '../repositories/customers_repository.dart';

class GetCustomers {
  GetCustomers(this._repository);

  final CustomersRepository _repository;

  Future<List<Customer>> call({int page = 1, int pageSize = 20}) {
    return _repository.getCustomers(page: page, pageSize: pageSize);
  }
}
