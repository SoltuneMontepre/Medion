import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/finished_product_dispatch_remote_datasource_impl.dart';
import '../../domain/entities/finished_product_release.dart';
import '../providers/finished_product_release_provider.dart';

/// Phiếu Xuất kho Thành phẩm — mỗi đơn hàng tạo 1 phiếu; tồn kho đủ mới xuất.
class FinishedProductReleasePage extends ConsumerStatefulWidget {
  const FinishedProductReleasePage({super.key});

  @override
  ConsumerState<FinishedProductReleasePage> createState() =>
      _FinishedProductReleasePageState();
}

class _FinishedProductReleasePageState
    extends ConsumerState<FinishedProductReleasePage> {
  String? _statusFilter;
  String _searchText = '';

  /// Show date only (YYYY-MM-DD), stripping time e.g. "2000-01-01T00:00:00 Z" → "2000-01-01".
  static String _dateOnly(String? value) {
    if (value == null || value.isEmpty) return '—';
    final t = value.indexOf('T');
    if (t > 0) return value.substring(0, t).trim();
    return value.trim();
  }

  void _invalidateList() {
    ref.invalidate(finishedProductReleasesProvider(_statusFilter));
  }

  Future<void> _submit(FinishedProductRelease release) async {
    final ds = ref.read(finishedProductDispatchRemoteDataSourceProvider);
    try {
      await ds.submit(release.id);
      if (!mounted) return;
      _invalidateList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi phiếu chờ Quản lý kho duyệt')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final msg = status == 403
          ? 'Bạn không có quyền thực hiện thao tác này'
          : (e.response?.data?['message']?.toString() ??
                e.message ??
                'Gửi duyệt thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approve(FinishedProductRelease release) async {
    final ds = ref.read(finishedProductDispatchRemoteDataSourceProvider);
    try {
      await ds.approve(release.id);
      if (!mounted) return;
      _invalidateList();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã duyệt phiếu xuất kho')));
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final msg = status == 403
          ? 'Bạn không có quyền thực hiện thao tác này'
          : (e.response?.data?['message']?.toString() ??
                e.message ??
                'Duyệt thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _reject(FinishedProductRelease release) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Yêu cầu sửa'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Lý do (bắt buộc)',
              hintText: 'Nhập lý do từ chối / yêu cầu sửa',
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
              onPressed: () {
                final t = controller.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(ctx, t);
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
    if (reason == null || !mounted) return;
    final ds = ref.read(finishedProductDispatchRemoteDataSourceProvider);
    try {
      await ds.reject(release.id, reason);
      if (!mounted) return;
      _invalidateList();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu sửa')));
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final msg = status == 403
          ? 'Bạn không có quyền thực hiện thao tác này'
          : (e.response?.data?['message']?.toString() ??
                e.message ??
                'Thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
      );
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Nháp';
      case 'pending_approval':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'revision_requested':
        return 'Yêu cầu sửa';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final releasesAsync = ref.watch(
      finishedProductReleasesProvider(_statusFilter),
    );

    return AppScaffold(
      title: 'Phiếu Xuất kho Thành phẩm',
      toolbarActions: [
        ToolbarButton(
          label: 'Thêm phiếu',
          icon: Icons.add,
          onPressed: () => context.push('/inventory/finished-release/create'),
        ),
        ToolbarButton(label: 'In', icon: Icons.print, onPressed: () {}),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bộ lọc phiếu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Trạng thái: ', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _statusFilter == null,
                          onSelected: (_) {
                            setState(() {
                              _statusFilter = null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Nháp'),
                          selected: _statusFilter == 'draft',
                          onSelected: (_) {
                            setState(() {
                              _statusFilter = 'draft';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Chờ duyệt'),
                          selected: _statusFilter == 'pending_approval',
                          onSelected: (_) {
                            setState(() {
                              _statusFilter = 'pending_approval';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Đã duyệt'),
                          selected: _statusFilter == 'approved',
                          onSelected: (_) {
                            setState(() {
                              _statusFilter = 'approved';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Yêu cầu sửa'),
                          selected: _statusFilter == 'revision_requested',
                          onSelected: (_) {
                            setState(() {
                              _statusFilter = 'revision_requested';
                            });
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        decoration: const InputDecoration(
                          isDense: true,
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Tìm theo số đơn / KH',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value.trim();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: releasesAsync.when(
              data: (result) => _buildList(result.items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<FinishedProductRelease> list) {
    final query = _searchText.toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (r) =>
                r.orderNumber.toLowerCase().contains(query) ||
                r.customerCode.toLowerCase().contains(query) ||
                r.customerName.toLowerCase().contains(query),
          )
          .toList();
    }
    if (list.isEmpty) {
      return const Center(child: Text('Chưa có phiếu xuất kho'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final release = list[index];
        const headingRowHeight = 40.0;
        const dataRowHeight = 36.0;
        final lines = release.lines;
        final lineCount = lines.length;
        final tableHeight =
            headingRowHeight +
            (lineCount > 0 ? lineCount * dataRowHeight : dataRowHeight);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Số đơn: ${release.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text('Mã KH: ${release.customerCode}'),
                    const SizedBox(width: 16),
                    Text(release.customerName),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(_statusLabel(release.status)),
                      backgroundColor: release.isApproved
                          ? Colors.green.shade100
                          : release.status == 'revision_requested'
                          ? Colors.orange.shade100
                          : release.status == 'pending_approval'
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                    ),
                    const Spacer(),
                    if (release.canEdit)
                      TextButton.icon(
                        onPressed: () => context.push(
                          '/inventory/finished-release/${release.id}/edit',
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Sửa'),
                      ),
                    if (release.canSubmit)
                      TextButton.icon(
                        onPressed: () => _submit(release),
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Gửi duyệt'),
                      ),
                    if (release.canApproveReject) ...[
                      TextButton.icon(
                        onPressed: () => _approve(release),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Duyệt'),
                      ),
                      TextButton.icon(
                        onPressed: () => _reject(release),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Từ chối'),
                      ),
                    ],
                  ],
                ),
                if (release.rejectionReason != null &&
                    release.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Yêu cầu sửa: ${release.rejectionReason}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Địa chỉ: ${release.address} • Điện thoại: ${release.phone}',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: tableHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 900,
                      height: tableHeight,
                      child: DataTable2(
                        columnSpacing: 8,
                        horizontalMargin: 0,
                        minWidth: 900,
                        headingRowHeight: headingRowHeight,
                        dataRowHeight: dataRowHeight,
                        columns: const [
                          DataColumn2(label: Text('STT'), fixedWidth: 44),
                          DataColumn2(label: Text('MÃ SP'), size: ColumnSize.S),
                          DataColumn2(
                            label: Text('Tên SP'),
                            size: ColumnSize.L,
                          ),
                          DataColumn2(label: Text('QUY'), size: ColumnSize.S),
                          DataColumn2(label: Text('Dạng'), size: ColumnSize.S),
                          DataColumn2(
                            label: Text('Số'),
                            size: ColumnSize.S,
                            numeric: true,
                          ),
                          DataColumn2(label: Text('Số lô'), size: ColumnSize.S),
                          DataColumn2(label: Text('NSX'), fixedWidth: 140),
                          DataColumn2(label: Text('HSD'), fixedWidth: 140),
                        ],
                        rows: lines.map((line) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${line.ordinal}')),
                              DataCell(Text(line.productCode)),
                              DataCell(Text(line.productName)),
                              DataCell(Text(line.specification)),
                              DataCell(Text(line.productForm)),
                              DataCell(Text('${line.quantity}')),
                              DataCell(Text(line.batchNumber ?? '—')),
                              DataCell(Text(_dateOnly(line.manufacturingDate))),
                              DataCell(Text(_dateOnly(line.expiryDate))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'NV Kế toán kho (Ký số)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Text(
                      'Trưởng QL Kho (Duyệt) - Ký số',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Text(
                      'Thủ kho (ký xuất kho) - Ký số',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
