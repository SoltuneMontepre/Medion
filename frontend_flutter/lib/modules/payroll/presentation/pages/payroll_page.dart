import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/payroll_record.dart';
import '../providers/payroll_provider.dart';

class PayrollPage extends ConsumerStatefulWidget {
  const PayrollPage({super.key});

  @override
  ConsumerState<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends ConsumerState<PayrollPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(payrollRecordsProvider(_page));

    return AppScaffold(
      title: 'Lương',
      toolbarActions: [
        ToolbarButton(
          label: 'Thêm',
          icon: Icons.add,
          onPressed: () {},
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
              message: 'Xóa bản ghi đã chọn?',
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
      child: recordsAsync.when(
        data: (records) => _buildGrid(records),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<PayrollRecord> records) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 500,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor:
          WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 48,
      dataRowHeight: 44,
      sortColumnIndex: _sortCol,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('Mã'),
          fixedWidth: 60,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Nhân viên'),
          size: ColumnSize.L,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Kỳ'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Số tiền'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
      ],
      rows: records.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(r.id)),
            DataCell(Text(r.employeeName)),
            DataCell(Text(r.period)),
            DataCell(Text(r.amount.toStringAsFixed(2))),
            DataCell(Text(r.status)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy bản ghi lương')),
    );
  }
}
