import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/order_summary.dart';
import '../providers/order_summary_provider.dart';

/// Bảng Tổng hợp Đơn đặt hàng — read-only, theo ngày. Sale admin xem bảng của mình.
class OrderSummaryPage extends ConsumerStatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  ConsumerState<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends ConsumerState<OrderSummaryPage> {
  DateTime _selectedDate = DateTime.now();
  int _listPage = 1;
  static const _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDateToYyyyMmDd(_selectedDate);
    final summaryAsync = ref.watch(orderSummaryByDateProvider(dateStr));
    final listAsync = ref.watch(
        orderSummaryListProvider((page: _listPage, pageSize: _pageSize)));

    return AppScaffold(
      title: 'Bảng Tổng hợp Đơn đặt hàng',
      toolbarActions: [
        ToolbarButton(
          label: 'Hôm nay',
          icon: Icons.today,
          onPressed: () => setState(() => _selectedDate = DateTime.now()),
        ),
        ToolbarButton(
          label: 'Chọn ngày',
          icon: Icons.calendar_month,
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && mounted) {
              setState(() => _selectedDate = picked);
            }
          },
        ),
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ngày tổng hợp: ${_formatDisplayDate(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5E35B1),
              ),
            ),
          ),
          Expanded(
            child: summaryAsync.when(
              data: (summary) {
                if (summary == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có bảng tổng hợp cho ngày này',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildTable(context, summary);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Lỗi: $e',
                      style: const TextStyle(color: Colors.red))),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: listAsync.when(
              data: (result) => PaginationFooter(
                currentPage: _listPage,
                totalItems: result.total,
                onPrevious: _listPage > 1
                    ? () => setState(() => _listPage--)
                    : null,
                onNext: (_listPage * _pageSize) < result.total
                    ? () => setState(() => _listPage++)
                    : null,
              ),
              loading: () => const SizedBox(height: 32),
              error: (e, _) => const SizedBox(height: 32),
            ),
          ),
          if (listAsync.valueOrNull != null &&
              listAsync.valueOrNull!.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Các ngày đã có bảng (bấm để xem)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 44,
              child: listAsync.when(
                data: (result) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: result.items.map((e) {
                    final isSelected =
                        e.summaryDate == formatDateToYyyyMmDd(_selectedDate);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          _formatDisplayDateFromStr(e.summaryDate),
                        ),
                        onPressed: () => setState(() {
                          _selectedDate = DateTime.tryParse(e.summaryDate) ??
                              _selectedDate;
                        }),
                        backgroundColor: isSelected
                            ? const Color(0xFFE8E0F0)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDisplayDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatDisplayDateFromStr(String s) {
    final d = DateTime.tryParse(s);
    if (d == null) return s;
    return _formatDisplayDate(d);
  }

  Widget _buildTable(BuildContext context, OrderSummary summary) {
    const headingRowHeight = 48.0;
    const dataRowHeight = 44.0;
    const tableWidth = 700.0;
    final items = summary.items;
    final rowCount = items.isEmpty ? 0 : items.length;
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
      rows: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return DataRow(
          cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Text(item.productCode)),
            DataCell(Text(item.productName)),
            DataCell(Text(item.specification)),
            DataCell(Text(item.productType)),
            DataCell(Text(item.packagingType)),
            DataCell(Text(
              '${item.quantity}',
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
