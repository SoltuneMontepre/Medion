import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/breadcrumb.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../domain/entities/sale_order.dart';
import '../providers/sales_provider.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  int _page = 1;
  int _pageSize = 5;
  int _sortCol = 0;
  bool _sortAsc = true; // true = newest first (desc by date)
  String? _selectedId; // single selection
  static const _pageSizeOptions = [5, 10, 20];

  // Filters and sort (sent to API)
  String _searchQuery = '';
  String? _dateFilterValue; // null = all, 'today', 'week', 'month'
  String? _statusFilterValue;
  String? _channelFilterValue; // UI only; backend has no channel filter yet
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Show date only as DD/MM/YYYY. Handles ISO (2026-03-12T...) and "DD/MM/YYYY HH:mm".
  static String _formatDateSimple(String dateStr) {
    final trimmed = dateStr.trim();
    // ISO-like: 2026-03-12 or 2026-03-12T17:35:04...
    if (trimmed.length >= 10 && trimmed[4] == '-' && trimmed[7] == '-') {
      final y = trimmed.substring(0, 4);
      final m = trimmed.substring(5, 7);
      final d = trimmed.substring(8, 10);
      return '$d/$m/$y';
    }
    // Already "DD/MM/YYYY" or "DD/MM/YYYY HH:mm" — strip time
    final space = trimmed.indexOf(' ');
    return space > 0 ? trimmed.substring(0, space) : trimmed;
  }

  static String _formatMoney(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    var i = 0;
    for (var j = s.length - 1; j >= 0; j--) {
      if (i > 0 && i % 3 == 0) buf.write('.');
      buf.write(s[j]);
      i++;
    }
    return '${buf.toString().split('').reversed.join()}₫';
  }

  static Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower == 'draft') return const Color(0xFFFFB74D);
    if (lower == 'signed') return const Color(0xFF42A5F5);
    if (lower.contains('chờ') || lower.contains('pending'))
      return const Color(0xFFFFB74D);
    if (lower.contains('xác nhận') || lower.contains('confirm'))
      return const Color(0xFF42A5F5);
    if (lower.contains('xử l') || lower.contains('process'))
      return const Color(0xFF66BB6A);
    if (lower.contains('hủy') || lower.contains('cancel')) return Colors.grey;
    return const Color(0xFF66BB6A);
  }

  static String _statusLabel(String code) {
    switch (code) {
      case 'draft':
        return 'Chờ xác nhận';
      case 'signed':
        return 'Đã xác nhận';
      default:
        return code;
    }
  }

  OrdersListQuery _buildQuery() {
    return OrdersListQuery(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
      dateFilter: _dateFilterValue,
      status: _statusFilterValue ?? '',
      sortBy: 'order_date',
      sortOrder: _sortAsc ? 'desc' : 'asc',
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();
    final ordersAsync = ref.watch(salesOrdersProvider(query));

    return Container(
      color: const Color(0xFFF3F6FB),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: ordersAsync.when(
        data: (result) => _buildContent(context, result),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SaleOrdersListResult result) {
    final total = result.total;
    final lastPage = _pageSize > 0
        ? ((total + _pageSize - 1) / _pageSize).ceil()
        : 1;
    final hasNextPage = _page < lastPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Breadcrumb(
          items: ['Bán hàng', 'Đơn đặt hàng', 'Danh sách đơn hàng'],
        ),
        const SizedBox(height: 16),
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildFilterRow(context),
        const SizedBox(height: 16),
        if (_selectedId != null) _buildRowActions(context),
        if (_selectedId != null) const SizedBox(height: 8),
        Expanded(child: _buildOrdersCard(context, result.items, result.total)),
        PaginationFooter(
          currentPage: _page,
          totalItems: total,
          pageSize: _pageSize,
          itemLabel: 'đơn hàng',
          summaryStyle: true,
          onFirst: () => setState(() => _page = 1),
          onPrevious: _page > 1 ? () => setState(() => _page--) : null,
          onNext: hasNextPage ? () => setState(() => _page++) : null,
          onLast: lastPage > 1 ? () => setState(() => _page = lastPage) : null,
          onPageSelected: (p) => setState(() => _page = p),
          onPageSizeChanged: (s) => setState(() {
            _pageSize = s;
            _page = 1;
          }),
          pageSizeOptions: _pageSizeOptions,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        FilledButton.icon(
          onPressed: () => context.push('/customers/new-order'),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Khởi tạo đơn đặt hàng mới'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ],
    );
  }

  /// Backend uses 'draft' | 'signed'; display labels in Vietnamese.
  static const _statusOptions = [
    ('draft', 'Chờ xác nhận'),
    ('signed', 'Đã xác nhận'),
  ];
  static const _channelOptions = [
    ('retail', 'Bán lẻ'),
    ('wholesale', 'Bán sỉ'),
    ('online', 'Online'),
  ];

  Widget _buildFilterRow(BuildContext context) {
    final inputDecoration = InputDecoration(
      hintText: 'Tìm theo tên khách hàng hoặc mã đơn hàng',
      prefixIcon: const Icon(Icons.search, size: 20),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8DEE8), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: inputDecoration,
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _page = 1;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    value: _dateFilterValue,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    hint: const Text('Ngày đặt'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                      DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Tháng này'),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _dateFilterValue = v;
                      _page = 1;
                    }),
                  ),
                ),
                SizedBox(
                  width: 156,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    value: _statusFilterValue,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    hint: const Text('Trạng thái'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ..._statusOptions.map(
                        (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _statusFilterValue = v;
                      _page = 1;
                    }),
                  ),
                ),
                SizedBox(
                  width: 130,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    value: _channelFilterValue,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    hint: const Text('Kênh bán'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ..._channelOptions.map(
                        (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _channelFilterValue = v;
                      _page = 1;
                    }),
                  ),
                ),
                InputChip(
                  label: const Text('Mới nhất trước'),
                  avatar: Icon(
                    Icons.sort,
                    size: 18,
                    color: _sortAsc
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  selected: _sortAsc,
                  onPressed: () => setState(() => _sortAsc = !_sortAsc),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {
            if (_selectedId != null) context.push('/customers/orders/$_selectedId');
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Chi tiết'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Sửa'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: 'Xóa',
              message: 'Xóa đơn hàng đã chọn?',
              isDestructive: true,
            );
            if (ok && mounted) setState(() => _selectedId = null);
          },
          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
          label: const Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildOrdersCard(
    BuildContext context,
    List<SaleOrder> orders,
    int totalCount,
  ) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Danh sách đơn đặt hàng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalCount đơn hàng',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Đơn mới nhất được ưu tiên hiển thị ở đầu danh sách.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildGrid(orders)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<SaleOrder> orders) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 0,
      minWidth: 700,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 44,
      dataRowHeight: 44,
      sortColumnIndex: _sortCol,
      sortAscending: _sortAsc,
      columns: [
        const DataColumn2(
          label: Text(''),
          fixedWidth: 52,
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Mã đơn'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = 1;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Khách hàng'),
          size: ColumnSize.L,
          onSort: (i, asc) => setState(() {
            _sortCol = 2;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Ngày đặt'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = 3;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Trạng thái'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = 4;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Tổng tiền'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (i, asc) => setState(() {
            _sortCol = 5;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('Phụ trách'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = 6;
            _sortAsc = asc;
          }),
        ),
      ],
      rows: orders.map((o) {
        final selected = _selectedId == o.id;
        return DataRow(
          selected: selected,
          color: WidgetStateProperty.resolveWith((states) {
            if (selected) return const Color(0xFFE8E0F0);
            return null;
          }),
          cells: [
            DataCell(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _selectedId = (_selectedId == o.id) ? null : o.id;
                  });
                },
                child: Radio<String?>(
                  value: o.id,
                  groupValue: _selectedId,
                  onChanged: (v) {
                    setState(() {
                      _selectedId = (_selectedId == o.id) ? null : o.id;
                    });
                  },
                ),
              ),
            ),
            DataCell(Text(o.orderNumber)),
            DataCell(Text(o.customerName)),
            DataCell(Text(_formatDateSimple(o.date))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(o.status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _statusLabel(o.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(o.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(_formatMoney(o.totalAmount), textAlign: TextAlign.right),
            ),
            DataCell(Text(o.responsiblePerson ?? '—')),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Không tìm thấy đơn bán hàng')),
    );
  }
}
