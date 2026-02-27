import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.currentPage,
    this.totalPages,
    this.totalItems,
    this.onPrevious,
    this.onNext,
  });

  final int currentPage;
  final int? totalPages;
  final int? totalItems;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text('$totalItems mục', style: theme.textTheme.bodyMedium),
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
}
