import 'customer.dart';

/// Result of a paginated customer list from the API.
class CustomerListResult {
  const CustomerListResult({required this.items, required this.total});

  final List<Customer> items;
  final int total;
}
