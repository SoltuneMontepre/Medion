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
import '../../domain/entities/customer.dart';
import '../providers/customers_provider.dart';

/// Bảng Tổng hợp Danh sách Khách hàng.
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider(_page));

    return AppScaffold(
      title: 'Danh sách Khách hàng',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo khách hàng mới',
          icon: Icons.add,
          onPressed: () => context.go('/customers/create'),
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
              message: 'Xóa khách hàng đã chọn?',
              isDestructive: true,
            );
            if (ok && mounted) {}
          },
          shortcut: const SingleActivator(LogicalKeyboardKey.delete),
        ),
      ],
      filterSection: FilterBar(onSearch: (query) {}),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: customersAsync.when(
        data: (list) => _buildGrid(list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<Customer> list) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 800,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 48,
      dataRowHeight: 44,
      sortColumnIndex: _sortCol,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('STT'),
          fixedWidth: 56,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('MÃ'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Tên khách hàng'),
          size: ColumnSize.L,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Địa chỉ'),
          size: ColumnSize.L,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Số điện thoại'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Người liên hệ'),
          size: ColumnSize.M,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
      ],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Text(c.code)),
            DataCell(Text(c.name)),
            DataCell(Text(c.address)),
            DataCell(Text(c.phone)),
            DataCell(Text(c.contactPerson)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Chưa có khách hàng')),
    );
  }
}
