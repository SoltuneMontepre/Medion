import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  static const _navItems = <_NavItem>[
    _NavItem('/', 'Hồ sơ', Icons.folder),
    _NavItem('/customers', 'Danh mục', Icons.list),
    _NavItem('/inventory', 'Nhập & Xuất', Icons.import_export),
    _NavItem('/sales', 'Thu & Chi', Icons.payments),
    _NavItem('/reports', 'Báo cáo VT/HH', Icons.assessment),
    _NavItem('/security', 'Hệ thống', Icons.settings),
    _NavItem(null, 'Cửa sổ', Icons.window),
    _NavItem(null, 'Giúp đỡ', Icons.help_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = (String path) =>
        currentPath == path || (path != '/' && currentPath.startsWith(path));

    return Scaffold(
      body: Column(
        children: [
          // Odoo-like top navbar
          Material(
            elevation: 1,
            child: Container(
              height: 46,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  // Brand / Logo block (Odoo-style primary block)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        width: 200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        color: theme.colorScheme.primary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.apps,
                              color: theme.colorScheme.onPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MES Medion',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Horizontal nav items
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _navItems.map((item) {
                          final active = item.path != null && isActive(item.path!);
                          return _NavBarTile(
                            item: item,
                            active: active,
                            onTap: item.path != null
                                ? () => context.go(item.path!)
                                : () {},
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.label, this.icon);
  final String? path;
  final String label;
  final IconData icon;
}

class _NavBarTile extends StatelessWidget {
  const _NavBarTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: active
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
