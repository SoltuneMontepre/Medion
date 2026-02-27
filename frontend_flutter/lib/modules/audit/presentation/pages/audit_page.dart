import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/audit_log.dart';
import '../providers/audit_provider.dart';

class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogsProvider(_page));

    return AppScaffold(
      title: 'Nhật ký kiểm toán',
      toolbarActions: [
        ToolbarButton(
          label: 'Xuất',
          icon: Icons.download,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.keyE,
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
        searchHint: 'Tìm theo thao tác hoặc người dùng…',
        onSearch: (query) {},
      ),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: logsAsync.when(
        data: (logs) => _buildGrid(logs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<AuditLog> logs) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 700,
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
          label: const Text('Thao tác'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Người dùng'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Thời gian'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Loại đối tượng'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Mã đối tượng'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
      ],
      rows: logs.asMap().entries.map((entry) {
        final i = entry.key;
        final log = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(log.id)),
            DataCell(Text(log.action)),
            DataCell(Text(log.userId)),
            DataCell(Text(log.timestamp)),
            DataCell(Text(log.entityType)),
            DataCell(Text(log.entityId)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy bản ghi kiểm toán')),
    );
  }
}
