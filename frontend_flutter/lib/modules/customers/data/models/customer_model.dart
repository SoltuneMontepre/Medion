import '../../domain/entities/customer.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.phone,
    required this.contactPerson,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final String phone;
  final String contactPerson;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final name = json['name'] as String? ?? '$firstName $lastName'.trim();
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: name.isEmpty ? (json['name'] as String? ?? '') : name,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
    );
  }

  Customer toEntity() => Customer(
        id: id,
        code: code,
        name: name,
        address: address,
        phone: phone,
        contactPerson: contactPerson,
      );
}
