import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/order_summary.dart';
import '../providers/order_summary_provider.dart';

/// Bảng Tổng hợp Đơn đặt hàng — tổng hợp đơn của tất cả khách trong ngày theo MÃ SP.
class OrderSummaryPage extends ConsumerWidget {
  const OrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now();
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final summaryAsync = ref.watch(orderSummaryProvider(dateStr));

    return AppScaffold(
      title: 'Bảng Tổng hợp Đơn đặt hàng',
      toolbarActions: [
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
        ),
      ],
      child: summaryAsync.when(
        data: (summary) => _buildTable(context, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildTable(BuildContext context, OrderSummary summary) {
    const headingRowHeight = 48.0;
    const dataRowHeight = 44.0;
    const tableWidth = 700.0;
    final items = summary.items;
    final rowCount = items.length;
    final tableHeight =
        headingRowHeight + (rowCount > 0 ? rowCount * dataRowHeight : dataRowHeight);

    final table = DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      minWidth: tableWidth,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: headingRowHeight,
      dataRowHeight: dataRowHeight,
      columns: const [
        DataColumn2(label: Text('STT'), fixedWidth: 48),
        DataColumn2(label: Text('MÃ SP'), size: ColumnSize.S),
        DataColumn2(label: Text('Tên sản phẩm'), size: ColumnSize.L),
        DataColumn2(label: Text('Quy cách'), size: ColumnSize.S),
        DataColumn2(label: Text('Dạng'), size: ColumnSize.M),
        DataColumn2(label: Text('Đóng gói'), size: ColumnSize.S),
        DataColumn2(label: Text('Số'), size: ColumnSize.S, numeric: true),
      ],
      rows: items.map((item) {
        return DataRow(
          cells: [
            DataCell(Text('${item.ordinal}')),
            DataCell(Text(item.productCode)),
            DataCell(Text(item.productName)),
            DataCell(Text(item.specification)),
            DataCell(Text(item.productForm)),
            DataCell(Text(item.packagingForm)),
            DataCell(Text(
              '${item.totalQuantity}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            )),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Chưa có đơn hàng trong ngày')),
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          height: tableHeight,
          child: table,
        ),
      ),
    );
  }
}
