/// Domain entity. No Flutter, no JSON.
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;
}
