import '../entities/create_customer_params.dart';
import '../entities/customer.dart';
import '../repositories/customers_repository.dart';

class CreateCustomer {
  CreateCustomer(this._repository);

  final CustomersRepository _repository;

  Future<Customer> call(CreateCustomerParams params) {
    return _repository.createCustomer(params);
  }
}
