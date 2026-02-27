import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ToolbarButton {
  const ToolbarButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.shortcut,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SingleActivator? shortcut;

  String get shortcutLabel {
    if (shortcut == null) return '';
    final parts = <String>[];
    if (shortcut!.control) parts.add('Ctrl');
    if (shortcut!.shift) parts.add('Shift');
    if (shortcut!.alt) parts.add('Alt');
    final key = shortcut!.trigger;
    if (key == LogicalKeyboardKey.delete) {
      parts.add('Del');
    } else if (key == LogicalKeyboardKey.f2) {
      parts.add('F2');
    } else if (key == LogicalKeyboardKey.enter) {
      parts.add('Enter');
    } else {
      parts.add(key.keyLabel);
    }
    return parts.join('+');
  }
}

/// Visible text buttons (Add, Edit, Delete, Print). No icon-only actions.
class Toolbar extends StatelessWidget {
  const Toolbar({super.key, required this.buttons});

  final List<ToolbarButton> buttons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: buttons.map((b) {
          final hint = b.shortcutLabel;
          final tooltip =
              hint.isNotEmpty ? '${b.label} ($hint)' : b.label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: tooltip,
              child: b.icon != null
                  ? TextButton.icon(
                      onPressed: b.onPressed,
                      icon: Icon(b.icon, size: 20),
                      label: Text(b.label),
                    )
                  : TextButton(
                      onPressed: b.onPressed,
                      child: Text(b.label),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
