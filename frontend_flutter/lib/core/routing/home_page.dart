import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layout/app_scaffold.dart';

/// Dashboard overview: shows module status summary in a data grid.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _modules = <_ModuleRow>[
    _ModuleRow('Khách hàng', '/customers', 'Hoạt động', 'Danh sách KH'),
    _ModuleRow('Kho hàng', '/inventory', 'Hoạt động', '124 mục'),
    _ModuleRow('Xuất kho TP', '/inventory/finished-release', 'Hoạt động', 'Phiếu xuất'),
    _ModuleRow('Sản xuất', '/production', 'Hoạt động', '56 lệnh'),
    _ModuleRow('Kế hoạch SX', '/production/plan', 'Hoạt động', 'Bảng KH SX'),
    _ModuleRow('Bán hàng', '/sales', 'Hoạt động', '89 đơn'),
    _ModuleRow('Tổng hợp đơn hàng', '/sales/order-summary', 'Hoạt động', 'Theo ngày'),
    _ModuleRow('Kiểm soát chất lượng', '/qc', 'Hoạt động', '12 lần kiểm'),
    _ModuleRow('Nhật ký kiểm toán', '/audit', 'Hoạt động', '340 bản ghi'),
    _ModuleRow('Lương', '/payroll', 'Hoạt động', '78 bản ghi'),
    _ModuleRow('Duyệt', '/approval', 'Hoạt động', '5 chờ duyệt'),
    _ModuleRow('Bảo mật', '/security', 'OK', '\u2014'),
    _ModuleRow('Báo cáo', '/reports', 'Hoạt động', '15 báo cáo'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bảng điều khiển',
      child: DataTable2(
        columnSpacing: 16,
        horizontalMargin: 16,
        minWidth: 500,
        border: TableBorder.all(color: Colors.grey.shade300),
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
        headingRowHeight: 48,
        dataRowHeight: 52,
        columns: const [
          DataColumn2(label: Text('Mô-đun'), size: ColumnSize.L),
          DataColumn2(label: Text('Trạng thái'), size: ColumnSize.S),
          DataColumn2(label: Text('Tóm tắt'), size: ColumnSize.M),
        ],
        rows: _modules.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          return DataRow(
            color: WidgetStateProperty.all(
              i.isEven ? Colors.white : const Color(0xFFFAFAFA),
            ),
            cells: [
              DataCell(
                Text(
                  m.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1565C0),
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () => context.go(m.path),
              ),
              DataCell(Text(m.status)),
              DataCell(Text(m.summary)),
            ],
          );
        }).toList(),
        empty: const Center(child: Text('Không có mô-đun')),
      ),
    );
  }
}

class _ModuleRow {
  const _ModuleRow(this.name, this.path, this.status, this.summary);
  final String name;
  final String path;
  final String status;
  final String summary;
}
