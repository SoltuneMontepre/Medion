import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({
    super.key,
    required this.items,
  });

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 13,
      color: Colors.grey.shade700,
    );
    final activeStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            items[i],
            style: i == items.length - 1 ? activeStyle : baseStyle,
          ),
        ],
      ],
    );
  }
}

