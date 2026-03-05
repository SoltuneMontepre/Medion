import '../models/production_plan_model.dart';

/// Production plan API: GET by date/id, create/update, submit, approve.
abstract class ProductionPlanRemoteDataSource {
  /// Returns plan for the given date (YYYY-MM-DD), or null if none.
  Future<ProductionPlanModel?> getByDate(String dateYyyyMmDd);

  /// Returns plan by id (for edit).
  Future<ProductionPlanModel?> getById(String id);

  /// Create a new plan for the given date (YYYY-MM-DD).
  /// [items] are raw JSON maps with keys: productId (String uuid), ordinal (int), plannedQuantity (int).
  Future<ProductionPlanModel> create(String dateYyyyMmDd, List<Map<String, dynamic>> items);

  /// Update an existing plan by id.
  /// [items] are raw JSON maps with keys: productId (String uuid), ordinal (int), plannedQuantity (int).
  Future<ProductionPlanModel> update(String id, String dateYyyyMmDd, List<Map<String, dynamic>> items);

  /// Submit plan (draft → submitted). Returns updated plan.
  Future<ProductionPlanModel> submit(String planId);

  /// Approve plan (submitted → approved). Returns updated plan.
  Future<ProductionPlanModel> approve(String planId);

  /// Reject plan (submitted → draft). Returns updated plan.
  Future<ProductionPlanModel> reject(String planId, String reason);

  /// Suggest products by code/name for picker. GET /api/v1/sale/products/suggest?q=...
  Future<List<ProductSuggestItem>> suggestProducts(String query);
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
