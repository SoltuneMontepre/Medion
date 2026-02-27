import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/finished_product_release.dart';

/// Phiếu Xuất kho Thành phẩm. Mock data until API exists.
final finishedProductReleasesProvider =
    FutureProvider.autoDispose.family<List<FinishedProductRelease>, int>(
        (ref, page) async {
  await Future.delayed(const Duration(milliseconds: 250));
  return [
    FinishedProductRelease(
      id: '1',
      customerCode: '1111',
      customerName: 'AAAA',
      address: '....',
      phone: '....',
      orderNumber: 'XYZ',
      lines: [
        const FinishedProductReleaseLine(
          ordinal: 1,
          productCode: '111',
          productName: 'Amox 10%',
          specification: '100gr',
          productForm: 'Bột uống',
          packagingForm: 'Gói',
          quantity: 100,
        ),
        const FinishedProductReleaseLine(
          ordinal: 2,
          productCode: '222',
          productName: 'Ampi 20%',
          specification: '250gr',
          productForm: 'Bột uống',
          packagingForm: 'Gói',
          quantity: 200,
        ),
        const FinishedProductReleaseLine(
          ordinal: 3,
          productCode: '333',
          productName: 'Enro 10%',
          specification: '100ml',
          productForm: 'Dung dịch',
          packagingForm: 'Chai',
          quantity: 300,
        ),
      ],
    ),
  ];
});
