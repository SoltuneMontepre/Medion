import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/finished_product_release.dart';
import '../providers/finished_product_release_provider.dart';

/// Phiếu Xuất kho Thành phẩm — mỗi đơn hàng tạo 1 phiếu; tồn kho đủ mới xuất.
class FinishedProductReleasePage extends ConsumerStatefulWidget {
  const FinishedProductReleasePage({super.key});

  @override
  ConsumerState<FinishedProductReleasePage> createState() =>
      _FinishedProductReleasePageState();
}

class _FinishedProductReleasePageState
    extends ConsumerState<FinishedProductReleasePage> {
  final int _page = 1;

  @override
  Widget build(BuildContext context) {
    final releasesAsync = ref.watch(finishedProductReleasesProvider(_page));

    return AppScaffold(
      title: 'Phiếu Xuất kho Thành phẩm',
      toolbarActions: [
        ToolbarButton(
          label: 'Thêm phiếu',
          icon: Icons.add,
          onPressed: () {},
        ),
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
        ),
      ],
      child: releasesAsync.when(
        data: (list) => _buildList(list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildList(List<FinishedProductRelease> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Chưa có phiếu xuất kho'));
    }
    final safeList = list.whereType<FinishedProductRelease>().toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: safeList.length,
      itemBuilder: (context, index) {
        final release = safeList[index];
        const headingRowHeight = 40.0;
        const dataRowHeight = 36.0;
        final lines = release.lines;
        final lineCount = lines.length;
        final tableHeight = headingRowHeight +
            (lineCount > 0 ? lineCount * dataRowHeight : dataRowHeight);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Số đơn: ${release.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text('Mã KH: ${release.customerCode}'),
                    const SizedBox(width: 16),
                    Text(release.customerName),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Địa chỉ: ${release.address} • Điện thoại: ${release.phone}'),
                const SizedBox(height: 12),
                SizedBox(
                  height: tableHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 700,
                      height: tableHeight,
                      child: DataTable2(
                        columnSpacing: 8,
                        horizontalMargin: 0,
                        minWidth: 700,
                        headingRowHeight: headingRowHeight,
                        dataRowHeight: dataRowHeight,
                        columns: const [
                          DataColumn2(label: Text('STT'), fixedWidth: 44),
                          DataColumn2(label: Text('MÃ SP'), size: ColumnSize.S),
                          DataColumn2(label: Text('Tên SP'), size: ColumnSize.L),
                          DataColumn2(label: Text('QUY'), size: ColumnSize.S),
                          DataColumn2(label: Text('Dạng'), size: ColumnSize.S),
                          DataColumn2(label: Text('Số'), size: ColumnSize.S, numeric: true),
                          DataColumn2(label: Text('Số lô'), size: ColumnSize.S),
                          DataColumn2(label: Text('NSX'), size: ColumnSize.S),
                          DataColumn2(label: Text('HSD'), size: ColumnSize.S),
                        ],
                        rows: lines.map((line) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${line.ordinal}')),
                              DataCell(Text(line.productCode)),
                              DataCell(Text(line.productName)),
                              DataCell(Text(line.specification)),
                              DataCell(Text(line.productForm)),
                              DataCell(Text('${line.quantity}')),
                              DataCell(Text(line.batchNumber ?? '—')),
                              DataCell(Text(line.manufacturingDate ?? '—')),
                              DataCell(Text(line.expiryDate ?? '—')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'NV Kế toán kho (Ký số)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Text(
                      'Trưởng QL Kho (Duyệt) - Ký số',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Text(
                      'Thủ kho (ký xuất kho) - Ký số',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
