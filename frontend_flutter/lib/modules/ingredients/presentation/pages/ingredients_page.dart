import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/repositories_impl/ingredients_repository_impl.dart';
import '../../domain/entities/ingredient.dart';
import '../providers/ingredients_provider.dart';
import '../widgets/ingredient_form_dialog.dart';

const int _pageSize = 20;

/// Danh sách Nguyên liệu (MÃ NL, Tên, Đơn vị).
class IngredientsPage extends ConsumerStatefulWidget {
  const IngredientsPage({super.key});

  @override
  ConsumerState<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends ConsumerState<IngredientsPage> {
  int _page = 1;
  String _searchQuery = '';
  Ingredient? _selectedIngredient;

  static List<Ingredient> _filter(List<Ingredient> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((p) {
      return p.code.toLowerCase().contains(q) ||
          p.name.toLowerCase().contains(q) ||
          p.unit.toLowerCase().contains(q);
    }).toList();
  }

  void _clearSelection() {
    if (_selectedIngredient != null) setState(() => _selectedIngredient = null);
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(ingredientsProvider(_page));
    final totalPages = resultAsync.valueOrNull != null
        ? ((resultAsync.valueOrNull!.total + _pageSize - 1) / _pageSize)
            .ceil()
            .clamp(1, 0x7fffffff)
        : 1;

    final repo = ref.read(ingredientsRepositoryProvider);

    return AppScaffold(
      title: 'Danh sách Nguyên liệu',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo mới',
          icon: Icons.add,
          onPressed: () async {
            final created = await showIngredientFormDialog(
              context,
              repository: repo,
            );
            if (created != null && mounted) {
              ref.invalidate(ingredientsProvider(_page));
              _clearSelection();
            }
          },
        ),
        ToolbarButton(
          label: 'Sửa',
          icon: Icons.edit,
          onPressed: _selectedIngredient == null
              ? null
              : () async {
                  final updated = await showIngredientFormDialog(
                    context,
                    ingredient: _selectedIngredient,
                    repository: repo,
                  );
                  if (updated != null && mounted) {
                    ref.invalidate(ingredientsProvider(_page));
                    setState(() => _selectedIngredient = updated);
                  }
                },
        ),
        ToolbarButton(
          label: 'Xóa',
          icon: Icons.delete,
          onPressed: _selectedIngredient == null
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Xóa nguyên liệu',
                    message:
                        'Bạn có chắc muốn xóa "${_selectedIngredient!.name}" (${_selectedIngredient!.code})?',
                    isDestructive: true,
                  );
                  if (!ok || !mounted) return;
                  try {
                    await repo.deleteIngredient(_selectedIngredient!.id);
                    if (mounted) {
                      ref.invalidate(ingredientsProvider(_page));
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
            ref.invalidate(ingredientsProvider(_page));
            _clearSelection();
          },
        ),
      ],
      filterSection: FilterBar(
        searchHint: 'Tìm theo mã, tên, đơn vị…',
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
                onPressed: () => ref.invalidate(ingredientsProvider(_page)),
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
      List<Ingredient> fullList, List<Ingredient> filtered, int total) {
    if (fullList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Chưa có nguyên liệu',
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

  Widget _buildGrid(List<Ingredient> list) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 600,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: 48,
      dataRowHeight: 44,
      columns: const [
        DataColumn2(label: Text('STT'), fixedWidth: 56),
        DataColumn2(label: Text('MÃ NL'), size: ColumnSize.S),
        DataColumn2(label: Text('TÊN NGUYÊN LIỆU'), size: ColumnSize.L),
        DataColumn2(label: Text('ĐƠN VỊ'), size: ColumnSize.S),
        DataColumn2(label: Text('GHI CHÚ'), size: ColumnSize.M),
      ],
      rows: list.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final selected = _selectedIngredient?.id == p.id;
        return DataRow(
          selected: selected,
          onSelectChanged: (_) =>
              setState(() => _selectedIngredient = selected ? null : p),
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
            DataCell(Text(p.unit)),
            DataCell(Text(p.description)),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Chưa có nguyên liệu')),
    );
  }
}
