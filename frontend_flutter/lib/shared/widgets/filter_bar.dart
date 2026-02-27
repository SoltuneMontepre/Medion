import 'package:flutter/material.dart';

/// Optional filter chip entry: label and callback when removed.
class FilterChipEntry {
  const FilterChipEntry(this.label, {this.onRemove});
  final String label;
  final VoidCallback? onRemove;
}

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    this.onSearch,
    this.trailing,
    this.searchHint = 'Tìm kiếm…',
    this.filters,
    this.filterPanelBuilder,
    this.activeFilterChips,
    this.onClearAllFilters,
  });

  final ValueChanged<String>? onSearch;
  final List<Widget>? trailing;
  final String searchHint;

  /// Inline filter widgets (e.g. dropdowns, date pickers) shown next to the search bar.
  final List<Widget>? filters;

  /// When set, the filter button opens a bottom sheet with this content. If null, a placeholder message is shown.
  final WidgetBuilder? filterPanelBuilder;

  /// Chips shown for currently applied filters (e.g. "Kết quả: Đạt", "Từ: 01/01/2025").
  final List<FilterChipEntry>? activeFilterChips;

  /// Called when "Xóa bộ lọc" is tapped (optional; chips can also have per-chip onRemove).
  final VoidCallback? onClearAllFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveChips =
        activeFilterChips != null && activeFilterChips!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search field
              SizedBox(
                width: 260,
                height: 36,
                child: TextField(
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: onSearch,
                ),
              ),
              // Filter button (always visible; opens panel or placeholder)
              const SizedBox(width: 8),
              _FilterButton(
                hasActiveFilters: hasActiveChips,
                onTap: () => _openFilterPanel(context),
              ),
              // Inline filters (dropdowns, etc.)
              if (filters != null && filters!.isNotEmpty) ...[
                const SizedBox(width: 12),
                ...filters!
                    .expand((w) => [w, const SizedBox(width: 8)])
                    .toList()
                  ..removeLast(),
              ],
              const SizedBox(width: 12),
              if (trailing != null) ...trailing!,
            ],
          ),
          // Active filter chips
          if (hasActiveChips) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...activeFilterChips!.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InputChip(
                      label: Text(entry.label),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: entry.onRemove,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                if (onClearAllFilters != null)
                  TextButton(
                    onPressed: onClearAllFilters,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Xóa bộ lọc', style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openFilterPanel(BuildContext context) {
    final theme = Theme.of(context);
    final content = filterPanelBuilder != null
        ? filterPanelBuilder!(context)
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Chưa có bộ lọc cho trang này',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Bộ lọc',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.hasActiveFilters, required this.onTap});

  final bool hasActiveFilters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: hasActiveFilters
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: 'Bộ lọc',
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Badge(
              isLabelVisible: hasActiveFilters,
              child: Icon(
                Icons.filter_list,
                size: 22,
                color: hasActiveFilters
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
