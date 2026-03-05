import '../../domain/entities/ingredient.dart';

class IngredientModel {
  const IngredientModel({
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

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      description: json['description'] as String? ?? '',
    );
  }

  Ingredient toEntity() => Ingredient(
        id: id,
        code: code,
        name: name,
        unit: unit,
        description: description,
      );
}
