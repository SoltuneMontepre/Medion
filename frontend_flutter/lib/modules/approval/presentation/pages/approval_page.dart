import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalPage extends ConsumerStatefulWidget {
  const ApprovalPage({super.key});

  @override
  ConsumerState<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends ConsumerState<ApprovalPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(approvalRequestsProvider(_page));

    return AppScaffold(
      title: 'Duyệt',
      toolbarActions: [
        ToolbarButton(
          label: 'Duyệt',
          icon: Icons.check,
          onPressed: () {},
          shortcut: const SingleActivator(LogicalKeyboardKey.enter),
        ),
        ToolbarButton(
          label: 'Từ chối',
          icon: Icons.close,
          onPressed: () {},
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
      filterSection: FilterBar(
        searchHint: 'Tìm theo loại hoặc người yêu cầu…',
        onSearch: (query) {},
      ),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: requestsAsync.when(
        data: (requests) => _buildGrid(requests),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<ApprovalRequest> requests) {
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
          label: const Text('Loại'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Người yêu cầu'),
          size: ColumnSize.L,
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
      ],
      rows: requests.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(r.id)),
            DataCell(Text(r.requestType)),
            DataCell(Text(r.requester)),
            DataCell(Text(r.status)),
            DataCell(Text(r.date)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy yêu cầu duyệt')),
    );
  }
}
