/// Ingredient (nguyên liệu) master data.
class Ingredient {
  const Ingredient({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    this.description = '',
  });

  final String id;
  final String code;
  final String name;
  final String unit;
  final String description;
}
