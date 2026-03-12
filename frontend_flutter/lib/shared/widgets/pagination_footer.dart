import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.currentPage,
    this.totalPages,
    this.totalItems,
    this.onPrevious,
    this.onNext,
    this.summaryStyle = false,
    this.pageSize,
    this.itemLabel = 'mục',
    this.onFirst,
    this.onLast,
    this.onPageSelected,
    this.onPageSizeChanged,
    this.pageSizeOptions = const [5, 10, 20],
  });

  final int currentPage;
  final int? totalPages;
  final int? totalItems;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// When true: left = "1-5 trên 128 đơn hàng", center = << < 1 2 ... > >>, right = Mỗi trang dropdown.
  final bool summaryStyle;
  final int? pageSize;
  final String itemLabel;
  final VoidCallback? onFirst;
  final VoidCallback? onLast;
  final ValueChanged<int>? onPageSelected;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int> pageSizeOptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (summaryStyle && pageSize != null && totalItems != null) {
      return _buildOrderListStyle(context, theme);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            totalPages != null
                ? 'Trang $currentPage / $totalPages'
                : 'Trang $currentPage',
            style: theme.textTheme.bodyMedium,
          ),
          if (totalItems != null) ...[
            const SizedBox(width: 16),
            Text('$totalItems $itemLabel', style: theme.textTheme.bodyMedium),
          ],
          const Spacer(),
          TextButton(
            onPressed: onPrevious,
            child: const Text('Trước'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onNext,
            child: const Text('Sau'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListStyle(BuildContext context, ThemeData theme) {
    final size = pageSize!;
    final total = totalItems!;
    var totalPgs = (total / size).ceil().clamp(1, 0x7fffffff);
    // If caller indicates there is a "next" page (onNext != null) but our computed
    // total pages would not allow it, expand the page range optimistically so
    // the UI still enables the navigation controls. This is useful when the
    // backend does not expose the real total count and the caller only knows
    // whether more pages are available.
    if (onNext != null && currentPage >= totalPgs) {
      totalPgs = currentPage + 1;
    }
    final start = (currentPage - 1) * size + 1;
    final end = (currentPage * size).clamp(0, total);
    final summary = '$start–$end trên $total $itemLabel';
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 1 ? onFirst : null,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1 ? onPrevious : null,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              ..._pageNumbers(totalPgs).map((p) {
                final isCurrent = p == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: isCurrent ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: isCurrent ? null : () => onPageSelected?.call(p),
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Center(
                          child: Text(
                            p == -1 ? '...' : '$p',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isCurrent
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPgs ? onNext : null,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPgs ? onLast : null,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onPageSizeChanged != null) ...[
            Text(
              'Mỗi trang',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: pageSizeOptions.contains(size) ? size : pageSizeOptions.first,
              items: pageSizeOptions
                  .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                  .toList(),
              onChanged: (v) {
                if (v != null) onPageSizeChanged!(v);
              },
            ),
          ],
        ],
      ),
    );
  }

  List<int> _pageNumbers(int totalPgs) {
    if (totalPgs <= 7) {
      return List.generate(totalPgs, (i) => i + 1);
    }
    final cur = currentPage;
    final list = <int>[];
    list.add(1);
    if (cur > 3) list.add(-1);
    for (var p = (cur - 1).clamp(2, totalPgs - 1);
        p <= (cur + 1).clamp(2, totalPgs - 1);
        p++) {
      if (!list.contains(p)) list.add(p);
    }
    if (cur < totalPgs - 2) list.add(-1);
    if (totalPgs > 1) list.add(totalPgs);
    return list;
  }
}
