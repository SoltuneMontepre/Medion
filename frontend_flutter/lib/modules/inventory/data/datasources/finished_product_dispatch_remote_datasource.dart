import '../models/finished_product_release_model.dart';

/// API for Phiếu xuất kho Thành phẩm (finished product dispatch).
abstract class FinishedProductDispatchRemoteDataSource {
  /// List with optional status filter. limit/offset for pagination.
  Future<({List<FinishedProductReleaseModel> items, int total})> list({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<FinishedProductReleaseModel?> getById(String id);

  Future<FinishedProductReleaseModel> create({
    required String customerId,
    required String orderNumber,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> items,
  });

  Future<FinishedProductReleaseModel> update(
    String id, {
    required String orderNumber,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> items,
  });

  Future<FinishedProductReleaseModel> submit(String id);

  Future<FinishedProductReleaseModel> approve(String id);

  Future<FinishedProductReleaseModel> reject(String id, String reason);

  /// GET /api/v1/sale/customers/suggest?q=...
  Future<List<CustomerSuggestItem>> suggestCustomers(String query);

  /// GET /api/v1/sale/products/suggest?q=...
  Future<List<ProductSuggestItem>> suggestProducts(String query);
}

class CustomerSuggestItem {
  const CustomerSuggestItem({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.phone,
  });
  final String id;
  final String code;
  final String name;
  final String? address;
  final String? phone;
}

class ProductSuggestItem {
  const ProductSuggestItem({
    required this.id,
    required this.code,
    required this.name,
  });
  final String id;
  final String code;
  final String name;
}
