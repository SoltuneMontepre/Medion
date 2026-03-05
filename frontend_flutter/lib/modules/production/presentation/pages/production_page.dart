import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/production_order.dart';
import '../providers/production_provider.dart';

class ProductionPage extends ConsumerStatefulWidget {
  const ProductionPage({super.key});

  @override
  ConsumerState<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends ConsumerState<ProductionPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(productionOrdersProvider(_page));

    return AppScaffold(
      title: 'Sản xuất',
      toolbarActions: [
        ToolbarButton(
          label: 'Lập lệnh SX',
          icon: Icons.add,
          onPressed: () => context.push('/production/orders/create'),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
              control: true),
        ),
        ToolbarButton(
          label: 'Sửa',
          icon: Icons.edit,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.f2),
        ),
        ToolbarButton(
          label: 'Xóa',
          icon: Icons.delete,
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: 'Xóa',
              message: 'Xóa lệnh sản xuất đã chọn?',
              isDestructive: true,
            );
            if (ok && mounted) {}
          },
          shortcut: const SingleActivator(LogicalKeyboardKey.delete),
        ),
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.keyP,
              control: true),
        ),
      ],
      filterSection: FilterBar(onSearch: (query) {}),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: ordersAsync.when(
        data: (orders) => _buildGrid(orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<ProductionOrder> orders) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 600,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor:
          WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 48,
      dataRowHeight: 44,
      sortColumnIndex: _sortCol,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('Số LSX'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(label: const Text('Sản phẩm'), size: ColumnSize.L),
        DataColumn2(label: const Text('Số lô'), size: ColumnSize.S),
        DataColumn2(label: const Text('SL'), fixedWidth: 70, numeric: true),
        DataColumn2(label: const Text('Trạng thái'), size: ColumnSize.S),
        DataColumn2(label: const Text('Ngày SX'), size: ColumnSize.S),
      ],
      rows: orders.asMap().entries.map((entry) {
        final i = entry.key;
        final o = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(o.orderNumber)),
            DataCell(Text(o.productName)),
            DataCell(Text(o.batchNumber)),
            DataCell(Text('${o.quantitySpec1 + o.quantitySpec2}')),
            DataCell(Text(_statusLabel(o.status))),
            DataCell(Text(o.productionDate)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy lệnh sản xuất')),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Nháp';
      case 'active':
        return 'Đang SX';
      case 'done':
        return 'Hoàn thành';
      case 'canceled':
        return 'Hủy';
      default:
        return status;
    }
  }
}
