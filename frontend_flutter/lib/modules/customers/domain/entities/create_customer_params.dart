/// Parameters for creating or updating a customer.
/// For create: code and name are entered by Sales (NV phòng KD). Code is required.
/// For update: only name, address, phone, contactPerson are sent; code is not used.
class CreateCustomerParams {
  const CreateCustomerParams({
    this.code,
    required this.name,
    required this.address,
    required this.phone,
    this.contactPerson = '',
  });

  /// Required when creating; ignored when updating.
  final String? code;
  final String name;
  final String address;
  final String phone;
  /// Người liên hệ (contact person).
  final String contactPerson;
}
