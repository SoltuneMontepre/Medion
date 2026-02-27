import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/report.dart';
import '../providers/report_provider.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider(_page));

    return AppScaffold(
      title: 'Báo cáo',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo',
          icon: Icons.note_add,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN,
              control: true),
        ),
        ToolbarButton(
          label: 'Tải xuống',
          icon: Icons.download,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.keyD,
              control: true),
        ),
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.keyP,
              control: true),
        ),
      ],
      filterSection: FilterBar(
        searchHint: 'Tìm theo tiêu đề hoặc loại…',
        onSearch: (query) {},
      ),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: reportsAsync.when(
        data: (reports) => _buildGrid(reports),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<Report> reports) {
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
          label: const Text('Mã'),
          fixedWidth: 60,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Tiêu đề'),
          size: ColumnSize.L,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Loại'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Ngày'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Người tạo'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
      ],
      rows: reports.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(r.id)),
            DataCell(Text(r.title)),
            DataCell(Text(r.type)),
            DataCell(Text(r.status)),
            DataCell(Text(r.date)),
            DataCell(Text(r.createdBy)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy báo cáo')),
    );
  }
}
