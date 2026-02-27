import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/production_plan.dart';

/// Bảng Kế hoạch Sản xuất (theo ngày). Mock data until API exists.
final productionPlanProvider =
    FutureProvider.autoDispose.family<ProductionPlan, String>((ref, date) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return ProductionPlan(
    planDate: date,
    items: [
      const ProductionPlanItem(
        ordinal: 1,
        productCode: '111',
        productName: 'Amox 10%',
        specification: '100gr',
        productForm: 'Bột uống',
        packagingForm: 'Gói',
        plannedQuantity: 1000,
      ),
      const ProductionPlanItem(
        ordinal: 2,
        productCode: '222',
        productName: 'Ampi 20%',
        specification: '250gr',
        productForm: 'Bột uống',
        packagingForm: 'Gói',
        plannedQuantity: 2000,
      ),
      const ProductionPlanItem(
        ordinal: 3,
        productCode: '333',
        productName: 'Enro 10%',
        specification: '100ml',
        productForm: 'Dung dịch',
        packagingForm: 'Chai',
        plannedQuantity: 3500,
      ),
      const ProductionPlanItem(
        ordinal: 4,
        productCode: '444',
        productName: 'Flor 30%',
        specification: '1000 ml',
        productForm: 'Dung dịch',
        packagingForm: 'Chai',
        plannedQuantity: 200,
      ),
      const ProductionPlanItem(
        ordinal: 5,
        productCode: '555',
        productName: 'Amox hỗn dịch 15%',
        specification: '100ml',
        productForm: 'Hỗn dịch',
        packagingForm: 'Chai',
        plannedQuantity: 1000,
      ),
      const ProductionPlanItem(
        ordinal: 6,
        productCode: '666',
        productName: 'Cetriason',
        specification: '100ml',
        productForm: 'Bột pha',
        packagingForm: 'Chai',
        plannedQuantity: 500,
      ),
    ],
  );
});
