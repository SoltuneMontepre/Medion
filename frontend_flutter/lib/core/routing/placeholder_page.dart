import 'package:flutter/material.dart';

/// Shown for nav routes that are not implemented yet.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_outlined, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              title ?? 'Chức năng đang phát triển',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
