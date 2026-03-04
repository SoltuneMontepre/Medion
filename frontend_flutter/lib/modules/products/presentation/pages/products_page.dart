import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/repositories_impl/products_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';
import '../widgets/product_form_dialog.dart';

const int _pageSize = 20;

/// Danh sách Sản phẩm (MÃ SP, Tên, Quy cách, Dạng SP, Dạng đóng gói).
class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  int _page = 1;
  int _sortCol = 0;
  bool _sortAsc = true;
  String _searchQuery = '';
  Product? _selectedProduct;

  static List<Product> _filter(List<Product> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((p) {
      return p.code.toLowerCase().contains(q) ||
          p.name.toLowerCase().contains(q) ||
          p.productType.toLowerCase().contains(q) ||
          p.packagingType.toLowerCase().contains(q);
    }).toList();
  }

  void _clearSelection() {
    if (_selectedProduct != null) setState(() => _selectedProduct = null);
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(productsProvider(_page));
    final totalPages = resultAsync.valueOrNull != null
        ? ((resultAsync.valueOrNull!.total + _pageSize - 1) / _pageSize)
            .ceil()
            .clamp(1, 0x7fffffff)
        : 1;

    final repo = ref.read(productsRepositoryProvider);

    return AppScaffold(
      title: 'Danh sách Sản phẩm',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo mới',
          icon: Icons.add,
          onPressed: () async {
            final created = await showProductFormDialog(
              context,
              repository: repo,
            );
            if (created != null && mounted) {
              ref.invalidate(productsProvider(_page));
              _clearSelection();
            }
          },
        ),
        ToolbarButton(
          label: 'Sửa',
          icon: Icons.edit,
          onPressed: _selectedProduct == null
              ? null
              : () async {
                  final updated = await showProductFormDialog(
                    context,
                    product: _selectedProduct,
                    repository: repo,
                  );
                  if (updated != null && mounted) {
                    ref.invalidate(productsProvider(_page));
                    setState(() => _selectedProduct = updated);
                  }
                },
        ),
        ToolbarButton(
          label: 'Xóa',
          icon: Icons.delete,
          onPressed: _selectedProduct == null
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Xóa sản phẩm',
                    message:
                        'Bạn có chắc muốn xóa "${_selectedProduct!.name}" (${_selectedProduct!.code})?',
                    isDestructive: true,
                  );
                  if (!ok || !mounted) return;
                  try {
                    await repo.deleteProduct(_selectedProduct!.id);
                    if (mounted) {
                      ref.invalidate(productsProvider(_page));
                      _clearSelection();
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
        ),
        ToolbarButton(
          label: 'Làm mới',
          icon: Icons.refresh,
          onPressed: () {
            ref.invalidate(productsProvider(_page));
            _clearSelection();
          },
        ),
      ],
      filterSection: FilterBar(
        searchHint: 'Tìm theo mã, tên, dạng SP…',
        onSearch: (query) => setState(() => _searchQuery = query),
      ),
      footer: PaginationFooter(
        currentPage: _page,
        totalPages: totalPages,
        totalItems: resultAsync.valueOrNull?.total,
        onPrevious: _page > 1
            ? () => setState(() {
                  _page--;
                  _clearSelection();
                })
            : null,
        onNext: _page < totalPages
            ? () => setState(() {
                  _page++;
                  _clearSelection();
                })
            : null,
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
                onPressed: () => ref.invalidate(productsProvider(_page)),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      List<Product> fullList, List<Product> filtered, int total) {
    if (fullList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Chưa có sản phẩm',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade600),
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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey.shade600),
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

  Widget _buildGrid(List<Product> list) {
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
          label: const Text('MÃ SP'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('TÊN SẢN PHẨM'),
          size: ColumnSize.L,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('QUY CÁCH'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('DẠNG SP'),
          size: ColumnSize.M,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn2(
          label: const Text('DẠNG ĐÓNG GÓI'),
          size: ColumnSize.S,
          onSort: (i, asc) => setState(() {
            _sortCol = i;
            _sortAsc = asc;
          }),
        ),
      ],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final selected = _selectedProduct?.id == p.id;
        return DataRow(
          selected: selected,
          onSelectChanged: (_) =>
              setState(() => _selectedProduct = selected ? null : p),
          color: WidgetStateProperty.all(
            selected
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5)
                : (i.isEven ? Colors.white : const Color(0xFFFAFAFA)),
          ),
          cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Text(p.code)),
            DataCell(Text(p.name)),
            DataCell(Text(p.specification)),
            DataCell(Text(p.productType)),
            DataCell(Text(p.packagingType)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Chưa có sản phẩm')),
    );
  }
}
