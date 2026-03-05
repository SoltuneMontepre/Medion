import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_provider.dart';
import 'nav_menu.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  /// Top-level item that contains [path] (for main tab highlight and sub-tabs).
  static NavItem? _activeSection(String path) {
    for (final item in NavMenu.items) {
      if (NavMenu.itemMatchesPath(item, path)) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final section = _activeSection(currentPath);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _MainTopBar(currentPath: currentPath, theme: theme),
          _SubTabBar(currentPath: currentPath, section: section),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MainTopBar extends ConsumerWidget {
  const _MainTopBar({required this.currentPath, required this.theme});

  final String currentPath;
  final ThemeData theme;

  static String _initials(String? username) {
    if (username == null || username.isEmpty) return '?';
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return username.length >= 2 ? username.substring(0, 2).toUpperCase() : username.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Material(
      elevation: 1,
      child: Container(
        height: 56,
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/inventory'),
                child: Container(
                  width: 160,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apps,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MES Medion',
                        style:
                            (theme.textTheme.titleLarge ??
                                    const TextStyle(fontSize: 20))
                                .copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: NavMenu.items.map((item) {
                    final active = NavMenu.itemMatchesPath(item, currentPath);
                    return _MainTabTile(
                      label: item.label,
                      active: active,
                      theme: theme,
                      onTap: () {
                        final path = NavMenu.firstPathOf(item);
                        if (path != null) context.go(path);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              tooltip: 'Thông báo',
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.go('/security'),
              tooltip: 'Cài đặt',
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              tooltip: auth.username ?? 'Tài khoản',
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _initials(auth.username),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    auth.username ?? 'Đã đăng nhập',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _MainTabTile extends StatelessWidget {
  const _MainTabTile({
    required this.label,
    required this.active,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool active;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Material(
      color: active ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: (theme.textTheme.titleMedium ?? const TextStyle(fontSize: 18))
                .copyWith(
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Second row: sub-tabs when the active section has children (e.g. Kho → kho NVP, kho BTP, kho TP).
class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.currentPath, required this.section});

  final String currentPath;
  final NavItem? section;

  /// True if [currentPath] matches this child's path (exact or prefix).
  static bool _pathMatches(NavItem child, String currentPath) {
    final p = child.path;
    if (p == null || p.isEmpty) return false;
    if (currentPath == p) return true;
    return p != '/' &&
        currentPath.startsWith(p) &&
        (currentPath.length == p.length || currentPath[p.length] == '/');
  }

  /// Among [children], only the one with the longest matching path is active (fixes multiple tabs highlighting).
  static NavItem? _activeSubChild(List<NavItem> children, String currentPath) {
    NavItem? best;
    int bestLen = 0;
    for (final child in children) {
      final p = child.path;
      if (p == null || p.isEmpty) continue;
      if (!_pathMatches(child, currentPath)) continue;
      if (p.length > bestLen) {
        bestLen = p.length;
        best = child;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    if (section == null || !section!.hasChildren) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final children = section!.children;
    final activeChild = _activeSubChild(children, currentPath);

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: children.map((child) {
            final path = child.path ?? '/';
            final active = activeChild != null &&
                activeChild.path != null &&
                activeChild.path == child.path;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Material(
                color: active ? colorScheme.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => context.go(path),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Text(
                      child.label,
                      style: (theme.textTheme.titleSmall ?? const TextStyle(fontSize: 16))
                          .copyWith(
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: active
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
