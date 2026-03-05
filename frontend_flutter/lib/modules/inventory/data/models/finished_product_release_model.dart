import '../../domain/entities/finished_product_release.dart';

/// Parses API payload (FinishedProductDispatchPayload) to domain entity.
class FinishedProductReleaseModel {
  const FinishedProductReleaseModel({
    required this.id,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.orderNumber,
    required this.status,
    required this.items,
    this.rejectionReason,
    this.approvedAt,
  });

  final String id;
  final String customerId;
  final String customerCode;
  final String customerName;
  final String address;
  final String phone;
  final String orderNumber;
  final String status;
  final List<FinishedProductReleaseLineModel> items;
  final String? rejectionReason;
  final DateTime? approvedAt;

  factory FinishedProductReleaseModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((e) => FinishedProductReleaseLineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final approvedAtRaw = json['approvedAt'] as String?;
    DateTime? approvedAt;
    if (approvedAtRaw != null && approvedAtRaw.isNotEmpty) {
      approvedAt = DateTime.tryParse(approvedAtRaw);
    }
    return FinishedProductReleaseModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerCode: json['customerCode'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      items: items,
      rejectionReason: json['rejectionReason'] as String?,
      approvedAt: approvedAt,
    );
  }

  FinishedProductRelease toEntity() => FinishedProductRelease(
        id: id,
        customerId: customerId,
        customerCode: customerCode,
        customerName: customerName,
        address: address,
        phone: phone,
        orderNumber: orderNumber,
        status: status,
        lines: items.map((e) => e.toEntity()).toList(),
        rejectionReason: rejectionReason,
        approvedAt: approvedAt,
      );
}

class FinishedProductReleaseLineModel {
  const FinishedProductReleaseLineModel({
    required this.ordinal,
    required this.productCode,
    required this.productName,
    required this.specification,
    required this.productForm,
    required this.packagingForm,
    required this.quantity,
    this.productId,
    this.lotNumber,
    this.manufacturingDate,
    this.expiryDate,
  });

  final int ordinal;
  final String productCode;
  final String productName;
  final String specification;
  final String productForm;
  final String packagingForm;
  final int quantity;
  final String? productId;
  final String? lotNumber;
  final String? manufacturingDate;
  final String? expiryDate;

  factory FinishedProductReleaseLineModel.fromJson(Map<String, dynamic> json) {
    final mfg = json['manufacturingDate'] as String?;
    final exp = json['expiryDate'] as String?;
    return FinishedProductReleaseLineModel(
      ordinal: (json['ordinal'] as num?)?.toInt() ?? 0,
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      productForm: json['productForm'] as String? ?? '',
      packagingForm: json['packagingForm'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      productId: json['productId']?.toString(),
      lotNumber: json['lotNumber'] as String?,
      manufacturingDate: mfg?.isNotEmpty == true ? mfg : null,
      expiryDate: exp?.isNotEmpty == true ? exp : null,
    );
  }

  FinishedProductReleaseLine toEntity() => FinishedProductReleaseLine(
        ordinal: ordinal,
        productCode: productCode,
        productName: productName,
        specification: specification,
        productForm: productForm,
        packagingForm: packagingForm,
        quantity: quantity,
        productId: productId,
        batchNumber: lotNumber,
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
      );
}
