import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/production_plan_remote_datasource_impl.dart';
import '../../domain/entities/production_plan.dart';
import '../providers/production_plan_provider.dart';

/// Bảng Kế hoạch Sản xuất — lập theo ngày sau khi kiểm tra tồn kho TP.
class ProductionPlanPage extends ConsumerStatefulWidget {
  const ProductionPlanPage({super.key});

  @override
  ConsumerState<ProductionPlanPage> createState() => _ProductionPlanPageState();
}

class _ProductionPlanPageState extends ConsumerState<ProductionPlanPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _dateToStr(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _submitPlan(String planId, String dateStr) async {
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    try {
      await ds.submit(planId);
      if (!mounted) return;
      ref.invalidate(productionPlanProvider(dateStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi kế hoạch chờ duyệt')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gửi duyệt thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approvePlan(String planId, String dateStr) async {
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    try {
      await ds.approve(planId);
      if (!mounted) return;
      ref.invalidate(productionPlanProvider(dateStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt kế hoạch sản xuất')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? e.message ?? 'Duyệt thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectPlan(String planId, String dateStr) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Từ chối kế hoạch sản xuất'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(
              labelText: 'Lý do từ chối (bắt buộc)',
              hintText: 'Nhập lý do yêu cầu sửa...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty || !mounted) return;
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    try {
      await ds.reject(planId, reason);
      if (!mounted) return;
      ref.invalidate(productionPlanProvider(dateStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối kế hoạch, chuyển về nháp')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? e.message ?? 'Từ chối thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _dateToStr(_selectedDate);
    final planAsync = ref.watch(productionPlanProvider(dateStr));

    return AppScaffold(
      title: 'Bảng Kế hoạch Sản xuất',
      toolbarActions: [
        ToolbarButton(
          label: 'In',
          icon: Icons.print,
          onPressed: () {},
        ),
        ToolbarButton(
          label: planAsync.valueOrNull?.id != null &&
                  planAsync.valueOrNull?.status == 'draft'
              ? 'Sửa kế hoạch'
              : 'Lập kế hoạch',
          icon: planAsync.valueOrNull?.id != null &&
                  planAsync.valueOrNull?.status == 'draft'
              ? Icons.edit
              : Icons.add,
          onPressed: () {
            final apiDate =
                '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
            final plan = planAsync.valueOrNull;
            if (plan?.id != null && plan?.status == 'draft') {
              context.push('/production/plan/${plan!.id}/edit');
            } else {
              context.push('/production/plan/create?date=$apiDate');
            }
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: () {
                    setState(() => _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Ngày trước',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null && mounted) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(dateStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    setState(() => _selectedDate =
                        _selectedDate.add(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Ngày sau',
                ),
              ],
            ),
          ),
          Expanded(
            child: planAsync.when(
              data: (plan) => _buildContent(context, plan, dateStr),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductionPlan plan, String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plan.id != null && plan.status != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _StatusChip(status: plan.status!),
                const SizedBox(width: 12),
                if (plan.status == 'draft') ...[
                  FilledButton.icon(
                    onPressed: () => _submitPlan(plan.id!, dateStr),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Gửi duyệt'),
                  ),
                ],
                if (plan.status == 'approved') ...[
          FilledButton.icon(
            onPressed: () => context.push('/production/orders/create'),
            icon: const Icon(Icons.add_circle, size: 18),
            label: const Text('Lập lệnh SX'),
          ),
        ],
        if (plan.status == 'submitted') ...[
                  FilledButton.icon(
                    onPressed: () => _approvePlan(plan.id!, dateStr),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Duyệt kế hoạch'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _rejectPlan(plan.id!, dateStr),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Không duyệt'),
                  ),
                ],
              ],
            ),
          ),
        ],
        Expanded(child: _buildTable(context, plan)),
      ],
    );
  }

  Widget _buildTable(BuildContext context, ProductionPlan plan) {
    const headingRowHeight = 48.0;
    const dataRowHeight = 44.0;
    const tableWidth = 700.0;
    final items = plan.items;
    final rowCount = items.length;
    final hasPlan = plan.id != null;
    final isEmpty = items.isEmpty;

    if (!hasPlan && isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có kế hoạch cho ngày này',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn "Lập kế hoạch" để tạo kế hoạch sản xuất',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final tableHeight =
        headingRowHeight + (rowCount > 0 ? rowCount * dataRowHeight : dataRowHeight);

    final table = DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      minWidth: tableWidth,
      border: TableBorder.all(color: Colors.grey.shade300),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
      headingRowHeight: headingRowHeight,
      dataRowHeight: dataRowHeight,
      columns: const [
        DataColumn2(label: Text('STT'), fixedWidth: 48),
        DataColumn2(label: Text('MÃ SP'), size: ColumnSize.S),
        DataColumn2(label: Text('Tên sản phẩm'), size: ColumnSize.L),
        DataColumn2(label: Text('Quy cách'), size: ColumnSize.S),
        DataColumn2(label: Text('Dạng'), size: ColumnSize.M),
        DataColumn2(label: Text('Đóng gói'), size: ColumnSize.S),
        DataColumn2(label: Text('Số'), size: ColumnSize.S, numeric: true),
      ],
      rows: items.map((item) {
        return DataRow(
          cells: [
            DataCell(Text('${item.ordinal}')),
            DataCell(Text(item.productCode)),
            DataCell(Text(item.productName)),
            DataCell(Text(item.specification)),
            DataCell(Text(item.productForm)),
            DataCell(Text(item.packagingForm)),
            DataCell(Text(
              '${item.plannedQuantity}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            )),
          ],
        );
      }).toList(),
      empty: const Center(child: Text('Chưa có dòng sản phẩm')),
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          height: tableHeight,
          child: table,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    switch (status) {
      case 'draft':
        label = 'Nháp';
        color = Colors.orange;
        break;
      case 'submitted':
        label = 'Chờ duyệt';
        color = Colors.blue;
        break;
      case 'approved':
        label = 'Đã duyệt';
        color = Colors.green;
        break;
      default:
        label = status;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
    );
  }
}
