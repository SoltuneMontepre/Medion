import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../providers/security_provider.dart';

/// Security info is a single-record view (not a paginated list).
class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(securityInfoProvider);

    return AppScaffold(
      title: 'Bảo mật',
      toolbarActions: [
        ToolbarButton(
          label: 'Đổi PIN',
          icon: Icons.pin,
          onPressed: () {},
        ),
        ToolbarButton(
          label: 'Đặt lại mật khẩu',
          icon: Icons.lock_reset,
          onPressed: () {},
        ),
      ],
      child: infoAsync.when(
        data: (info) => Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 16,
            minWidth: 400,
            border: TableBorder.all(color: Colors.grey.shade300),
            headingRowColor:
                WidgetStateProperty.all(const Color(0xFFE3F2FD)),
            headingRowHeight: 48,
            dataRowHeight: 44,
            columns: const [
              DataColumn2(label: Text('Thuộc tính'), size: ColumnSize.M),
              DataColumn2(label: Text('Giá trị'), size: ColumnSize.L),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Mã người dùng')),
                DataCell(Text(info.userId)),
              ]),
              DataRow(
                color: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                cells: [
                  const DataCell(Text('PIN giao dịch')),
                  DataCell(Text(info.transactionPinSet ? 'Đã đặt' : 'Chưa đặt')),
                ],
              ),
              DataRow(cells: [
                const DataCell(Text('Đăng nhập lần cuối')),
                DataCell(Text(info.lastLogin)),
              ]),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
