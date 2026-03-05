import 'package:flutter/material.dart';

import '../widgets/toolbar.dart';

/// Mandatory layout: Page Title, Toolbar, Filter, Data Grid, Footer.
/// All modules must use this. Consistency > creativity.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.toolbarActions,
    this.filterSection,
    this.footer,
  });

  final String title;
  final Widget child;
  final List<ToolbarButton>? toolbarActions;
  final Widget? filterSection;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (toolbarActions?.isNotEmpty == true)
          Toolbar(buttons: toolbarActions!),
        if (filterSection != null) filterSection!,
        Expanded(
          child: Container(
            color: theme.colorScheme.surface,
            child: RepaintBoundary(
              child: child,
            ),
          ),
        ),
        if (footer != null) footer!,
      ],
    );

    final shortcuts = <ShortcutActivator, VoidCallback>{};
    if (toolbarActions != null) {
      for (final action in toolbarActions!) {
        if (action.shortcut != null && action.onPressed != null) {
          shortcuts[action.shortcut!] = action.onPressed!;
        }
      }
    }

    if (shortcuts.isNotEmpty) {
      body = CallbackShortcuts(
        bindings: shortcuts,
        child: body,
      );
    }

    return body;
  }
}
