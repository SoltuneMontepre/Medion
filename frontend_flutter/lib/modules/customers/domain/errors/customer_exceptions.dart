/// Thrown when creating a customer with a phone number that already exists.
class CustomerDuplicatePhoneException implements Exception {
  CustomerDuplicatePhoneException([this.message]);

  final String? message;

  @override
  String toString() =>
      message ?? 'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.';
}
