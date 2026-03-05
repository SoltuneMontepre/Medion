import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Section landing: sub-tab selected → grid of actions (like reference UI).
class InventorySectionPage extends StatelessWidget {
  const InventorySectionPage({super.key, this.sub = 'raw'});

  /// 'raw' | 'semi' | 'finished' for which warehouse sub-tab.
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _ActionGrid(sub: sub),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.sub});

  final String sub;

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;
    const cardHeight = 120.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = (constraints.maxWidth - spacing * 2) / 3;
        return SingleChildScrollView(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Column 1: large card (2 rows) then nothing
                SizedBox(
                  width: colWidth,
                  child: Column(
                    children: [
                      SizedBox(
                        height: cardHeight * 2 + spacing,
                        child: _ActionCard(
                          label: 'Danh sách vật liệu',
                          icon: Icons.list_alt,
                          highlighted: true,
                          onTap: () => context.go('/inventory/list'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: spacing),
                // Column 2 & 3: 2x2 grid then 2 in bottom row
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Nhập kho',
                                icon: Icons.keyboard_arrow_down,
                                highlighted: false,
                                onTap: () {},
                              ),
                            ),
                          ),
                          const SizedBox(width: spacing),
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Xuất kho',
                                icon: Icons.keyboard_arrow_up,
                                highlighted: false,
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Kiểm kê',
                                icon: Icons.checklist,
                                highlighted: false,
                                onTap: () {},
                              ),
                            ),
                          ),
                          const SizedBox(width: spacing),
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Tồn kho hiện tại',
                                icon: Icons.inventory_2_outlined,
                                highlighted: false,
                                onTap: () {
                                  if (sub == 'semi') {
                                    context.go('/inventory/semi/balance');
                                  } else if (sub == 'finished') {
                                    context.go('/inventory/finished/balance');
                                  } else {
                                    context.go('/inventory/balance');
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Lịch sử giao dịch',
                                icon: Icons.history,
                                highlighted: false,
                                onTap: () {},
                              ),
                            ),
                          ),
                          const SizedBox(width: spacing),
                          Expanded(
                            child: SizedBox(
                              height: cardHeight,
                              child: _ActionCard(
                                label: 'Nhà cung cấp',
                                icon: Icons.local_shipping_outlined,
                                highlighted: false,
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacing),
                      SizedBox(
                        height: cardHeight,
                        child: _ActionCard(
                          label: 'Báo cáo kho',
                          icon: Icons.bar_chart,
                          highlighted: false,
                          onTap: () => context.go('/reports'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;

  static const _selectedColor = Color(0xFFE8E0F0);
  static const _purple = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? _selectedColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlighted ? _purple.withValues(alpha: 0.5) : Colors.grey.shade300,
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: highlighted ? _purple : Colors.grey.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
                  color: highlighted ? _purple : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
