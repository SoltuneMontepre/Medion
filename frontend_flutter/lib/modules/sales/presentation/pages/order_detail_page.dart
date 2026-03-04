import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/sales_remote_datasource_impl.dart';
import '../../data/models/order_detail_model.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  OrderDetailModel? _order;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = ref.read(salesRemoteDataSourceProvider);
    try {
      final o = await ds.getOrderById(widget.orderId);
      if (mounted) setState(() { _order = o; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chi tiết đơn hàng',
      toolbarActions: [
        ToolbarButton(
          label: 'Quay lại',
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.pop(),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(child: Text('Không tìm thấy đơn hàng'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Số đơn: ${_order!.orderNumber}',
                                      style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('Khách hàng: ${_order!.customerCode} - ${_order!.customerName}'),
                                  Text('Ngày: ${_order!.orderDate}'),
                                  Text('Trạng thái: ${_order!.status}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          DataTable(
                            columnSpacing: 16,
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
                            columns: const [
                              DataColumn(label: Text('MÃ SP')),
                              DataColumn(label: Text('Tên SP')),
                              DataColumn(label: Text('Quy cách')),
                              DataColumn(label: Text('Số lượng')),
                            ],
                            rows: _order!.items
                                .map((e) => DataRow(
                                      cells: [
                                        DataCell(Text(e.productCode)),
                                        DataCell(Text(e.productName)),
                                        DataCell(Text('${e.packageSize}${e.packageUnit}')),
                                        DataCell(Text('${e.quantity}')),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
