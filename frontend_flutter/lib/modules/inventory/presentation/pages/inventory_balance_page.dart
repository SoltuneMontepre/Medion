import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/inventory_balance.dart';
import '../providers/inventory_provider.dart';

/// Tồn kho hiện tại: list by warehouse type (raw = NVP, semi = BTP, finished = TP).
class InventoryBalancePage extends ConsumerStatefulWidget {
  const InventoryBalancePage({super.key, this.section = 'raw'});

  /// raw | semi | finished
  final String section;

  @override
  ConsumerState<InventoryBalancePage> createState() =>
      _InventoryBalancePageState();
}

class _InventoryBalancePageState extends ConsumerState<InventoryBalancePage> {
  int _page = 1;

  static String _sectionTitle(String section) {
    switch (section) {
      case 'semi':
        return 'kho BTP';
      case 'finished':
        return 'kho TP';
      default:
        return 'kho NVP';
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = (warehouseType: widget.section, page: _page);
    final balanceAsync = ref.watch(inventoryBalanceProvider(key));

    return AppScaffold(
      title: 'Tồn kho hiện tại - ${_sectionTitle(widget.section)}',
      toolbarActions: [
        ToolbarButton(
          label: 'Quay lại',
          icon: Icons.arrow_back,
          onPressed: () => context.go('/inventory'),
        ),
      ],
      footer: balanceAsync.when(
        data: (result) => PaginationFooter(
          currentPage: _page,
          totalItems: result.total,
          onPrevious: _page > 1 ? () => setState(() => _page--) : null,
          onNext: result.items.length >= 20
              ? () => setState(() => _page++)
              : null,
        ),
        loading: () => const SizedBox(height: 48),
        error: (_, __) => const SizedBox(height: 48),
      ),
      child: balanceAsync.when(
        data: (result) => _buildTable(result.items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildTable(List<InventoryBalance> items) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 800,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 48,
      dataRowHeight: 44,
      columns: const [
        DataColumn2(label: Text('STT'), size: ColumnSize.S),
        DataColumn2(label: Text('MÃ SP'), size: ColumnSize.S),
        DataColumn2(label: Text('TÊN SẢN PHẨM'), size: ColumnSize.L),
        DataColumn2(label: Text('QUY'), size: ColumnSize.S),
        DataColumn2(label: Text('DẠNG'), size: ColumnSize.M),
        DataColumn2(label: Text('DẠNG ĐÓNG GÓI'), size: ColumnSize.S),
        DataColumn2(label: Text('SỐ'), size: ColumnSize.S),
      ],
      rows: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final stt = (_page - 1) * 20 + i + 1;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text('$stt')),
            DataCell(Text(item.productCode)),
            DataCell(Text(item.productName)),
            DataCell(Text('${item.packageSize}${item.packageUnit}')),
            DataCell(Text(item.productType)),
            DataCell(Text(item.packagingType)),
            DataCell(Text('${item.quantity}')),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không có dữ liệu tồn kho')),
    );
  }
}
