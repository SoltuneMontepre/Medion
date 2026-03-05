/// Domain entity. No Flutter, no JSON.
/// Phiếu Xuất kho Thành phẩm: khách hàng, đơn hàng, danh sách SP (MÃ SP, TÊN, QUY, DẠNG, SỐ, SỐ LÔ, NSX, HSD).
class FinishedProductReleaseLine {
  const FinishedProductReleaseLine({
    required this.ordinal,
    required this.productCode,
    required this.productName,
    required this.specification,
    required this.productForm,
    required this.packagingForm,
    required this.quantity,
    this.productId,
    this.batchNumber,
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
  final String? batchNumber;
  final String? manufacturingDate;
  final String? expiryDate;
}

/// Status: draft, pending_approval, approved, revision_requested
class FinishedProductRelease {
  const FinishedProductRelease({
    required this.id,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.orderNumber,
    required this.status,
    required this.lines,
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
  final List<FinishedProductReleaseLine> lines;
  final String? rejectionReason;
  final DateTime? approvedAt;

  bool get canEdit =>
      status == 'draft' || status == 'revision_requested';
  bool get canSubmit =>
      status == 'draft' || status == 'revision_requested';
  bool get canApproveReject => status == 'pending_approval';
  bool get isApproved => status == 'approved';
}
