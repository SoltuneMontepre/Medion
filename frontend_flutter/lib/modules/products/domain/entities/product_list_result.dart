import 'product.dart';

class ProductListResult {
  const ProductListResult({required this.items, required this.total});

  final List<Product> items;
  final int total;
}
