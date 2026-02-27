/// Domain entity. No Flutter, no JSON.
/// Bảng Tổng hợp Danh sách Khách hàng: STT, MÃ, TÊN KHÁCH HÀNG, ĐỊA CHỈ, SỐ ĐIỆN, NGƯỜI LIÊN HỆ.
class Customer {
  const Customer({
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
}
