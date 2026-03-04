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

const int _pageSize = 20;

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
  String _searchQuery = '';
  Customer? _selectedCustomer;

  static List<Customer> _filter(List<Customer> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          (c.contactPerson.isNotEmpty && c.contactPerson.toLowerCase().contains(q)) ||
          c.address.toLowerCase().contains(q);
    }).toList();
  }

  void _clearSelection() {
    if (_selectedCustomer != null) setState(() => _selectedCustomer = null);
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(customersProvider(_page));
    final totalPages = resultAsync.valueOrNull != null
        ? ((resultAsync.valueOrNull!.total + _pageSize - 1) / _pageSize).ceil().clamp(1, 0x7fffffff)
        : 1;

    return AppScaffold(
      title: 'Danh sách Khách hàng',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo khách hàng mới',
          icon: Icons.add,
          onPressed: () async {
            await context.push('/customers/create');
            if (!mounted) return;
            ref.invalidate(customersProvider(_page));
            _clearSelection();
          },
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN, control: true),
        ),
        ToolbarButton(
          label: 'Sửa',
          icon: Icons.edit,
          onPressed: _selectedCustomer == null
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng sửa đang phát triển')),
                  );
                },
          shortcut: const SingleActivator(LogicalKeyboardKey.f2),
        ),
        ToolbarButton(
          label: 'Xóa',
          icon: Icons.delete,
          onPressed: _selectedCustomer == null
              ? null
              : () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Xóa',
                    message: 'Xóa khách hàng đã chọn?',
                    isDestructive: true,
                  );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng xóa đang phát triển')),
                    );
                  }
                },
          shortcut: const SingleActivator(LogicalKeyboardKey.delete),
        ),
        ToolbarButton(
          label: 'Làm mới',
          icon: Icons.refresh,
          onPressed: () {
            ref.invalidate(customersProvider(_page));
            _clearSelection();
          },
        ),
      ],
      filterSection: FilterBar(
        searchHint: 'Tìm theo tên, mã, SĐT…',
        onSearch: (query) => setState(() => _searchQuery = query),
      ),
      footer: PaginationFooter(
        currentPage: _page,
        totalPages: totalPages,
        totalItems: resultAsync.valueOrNull?.total,
        onPrevious: _page > 1 ? () => setState(() { _page--; _clearSelection(); }) : null,
        onNext: _page < totalPages ? () => setState(() { _page++; _clearSelection(); }) : null,
      ),
      child: resultAsync.when(
        data: (result) {
          final filtered = _filter(result.items, _searchQuery);
          return _buildContent(result.items, filtered, result.total);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(customersProvider(_page)),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Customer> fullList, List<Customer> filtered, int total) {
    if (fullList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Chưa có khách hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push('/customers/create'),
              icon: const Icon(Icons.add),
              label: const Text('Tạo khách hàng đầu tiên'),
            ),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Không có kết quả phù hợp với "$_searchQuery"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: _clearSelection,
      behavior: HitTestBehavior.opaque,
      child: _buildGrid(filtered),
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
        final selected = _selectedCustomer?.id == c.id;
        return DataRow(
          selected: selected,
          onSelectChanged: (_) => setState(() => _selectedCustomer = selected ? null : c),
          color: WidgetStateProperty.all(
            selected
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : (i.isEven ? Colors.white : const Color(0xFFFAFAFA)),
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
