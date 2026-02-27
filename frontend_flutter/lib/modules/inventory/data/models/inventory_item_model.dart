import '../../domain/entities/inventory_item.dart';

/// Data model with fromJson/toJson. Maps to domain entity.
class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  InventoryItem toEntity() => InventoryItem(id: id, code: code, name: name);
}
