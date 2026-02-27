import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/qc_inspection.dart';
import '../providers/qc_provider.dart';

class QcPage extends ConsumerStatefulWidget {
  const QcPage({super.key});

  @override
  ConsumerState<QcPage> createState() => _QcPageState();
}

class _QcPageState extends ConsumerState<QcPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;
  String _searchQuery = '';
  String? _resultFilter; // null = all, 'pass', 'fail', 'pending'

  static const _resultOptions = <String?>[null, 'pass', 'fail', 'pending'];
  static const _resultLabels = {'pass': 'Đạt', 'fail': 'Không đạt', 'pending': 'Chờ'};

  @override
  Widget build(BuildContext context) {
    final inspectionsAsync = ref.watch(qcInspectionsProvider(_page));

    return AppScaffold(
      title: 'Kiểm soát chất lượng',
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
              message: 'Xóa lần kiểm tra đã chọn?',
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
      filterSection: FilterBar(
        searchHint: 'Tìm theo lô, sản phẩm hoặc người kiểm…',
        onSearch: (query) => setState(() => _searchQuery = query),
        filters: [
          SizedBox(
            width: 140,
            height: 36,
            child: DropdownButtonFormField<String?>(
              value: _resultFilter,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Kết quả'),
              items: _resultOptions.map((v) => DropdownMenuItem<String?>(
                value: v,
                child: Text(v == null ? 'Tất cả' : (_resultLabels[v] ?? v)),
              )).toList(),
              onChanged: (v) => setState(() => _resultFilter = v),
            ),
          ),
        ],
        filterPanelBuilder: (ctx) => _buildFilterPanel(ctx),
        activeFilterChips: _resultFilter != null
            ? [
                FilterChipEntry(
                  'Kết quả: ${_resultLabels[_resultFilter] ?? _resultFilter}',
                  onRemove: () => setState(() => _resultFilter = null),
                ),
              ]
            : null,
        onClearAllFilters: () => setState(() => _resultFilter = null),
      ),
      footer: PaginationFooter(
        currentPage: _page,
        onPrevious: _page > 1 ? () => setState(() => _page--) : null,
        onNext: () => setState(() => _page++),
      ),
      child: inspectionsAsync.when(
        data: (inspections) => _buildGrid(_applyFilters(inspections)),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildGrid(List<QcInspection> inspections) {
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
          label: const Text('Lô #'),
          size: ColumnSize.S,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Sản phẩm'),
          size: ColumnSize.L,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Người kiểm'),
          size: ColumnSize.M,
          onSort: (i, asc) =>
              setState(() { _sortCol = i; _sortAsc = asc; }),
        ),
        DataColumn2(
          label: const Text('Kết quả'),
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
      rows: inspections.asMap().entries.map((entry) {
        final i = entry.key;
        final insp = entry.value;
        return DataRow(
          color: WidgetStateProperty.all(
            i.isEven ? Colors.white : const Color(0xFFFAFAFA),
          ),
          cells: [
            DataCell(Text(insp.id)),
            DataCell(Text(insp.batchNumber)),
            DataCell(Text(insp.productName)),
            DataCell(Text(insp.inspector)),
            DataCell(_resultBadge(insp.result)),
            DataCell(Text(insp.date)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy lần kiểm QC')),
    );
  }

  List<QcInspection> _applyFilters(List<QcInspection> list) {
    var out = list;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((e) =>
        e.batchNumber.toLowerCase().contains(q) ||
        e.productName.toLowerCase().contains(q) ||
        e.inspector.toLowerCase().contains(q) ||
        e.id.toLowerCase().contains(q),
      ).toList();
    }
    if (_resultFilter != null) {
      out = out.where((e) {
        final r = e.result.toLowerCase();
        return r == _resultFilter ||
            (_resultFilter == 'pass' && (r == 'đạt' || r == 'pass')) ||
            (_resultFilter == 'fail' && (r == 'không đạt' || r == 'fail')) ||
            (_resultFilter == 'pending' && (r == 'chờ' || r == 'pending'));
      }).toList();
    }
    return out;
  }

  Widget _buildFilterPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String?>(
          value: _resultFilter,
          decoration: const InputDecoration(
            labelText: 'Kết quả',
            border: OutlineInputBorder(),
          ),
          items: _resultOptions.map((v) => DropdownMenuItem<String?>(
            value: v,
            child: Text(v == null ? 'Tất cả' : (_resultLabels[v] ?? v)),
          )).toList(),
          onChanged: (v) => setState(() => _resultFilter = v),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }

  Widget _resultBadge(String result) {
    final color = switch (result.toLowerCase()) {
      'pass' => Colors.green,
      'fail' => Colors.red,
      'đạt' => Colors.green,
      'không đạt' => Colors.red,
      'chờ' => Colors.orange,
      _ => Colors.orange,
    };
    return Text(
      result,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
