import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/production_plan_remote_datasource_impl.dart';
import '../../data/models/production_plan_model.dart';
import '../providers/production_plan_provider.dart';

String _ddMmYyyyToYyyyMmDd(String ddMmYyyy) {
  final parts = ddMmYyyy.split('/');
  if (parts.length != 3) return ddMmYyyy;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

class _PlanItemInput {
  _PlanItemInput({
    this.productId = '',
    this.productDisplay = '',
    this.quantity = 0,
  });

  String productId;
  String productDisplay;
  int quantity;
}

class ProductionPlanEditPage extends ConsumerStatefulWidget {
  const ProductionPlanEditPage({
    super.key,
    this.initialDateYyyyMmDd,
    this.planId,
  });

  /// Initial plan date in YYYY-MM-DD format (e.g. from query param).
  final String? initialDateYyyyMmDd;

  /// When set, load existing plan for edit (draft only).
  final String? planId;

  @override
  ConsumerState<ProductionPlanEditPage> createState() =>
      _ProductionPlanEditPageState();
}

class _ProductionPlanEditPageState extends ConsumerState<ProductionPlanEditPage> {
  late TextEditingController _dateController;
  final List<_PlanItemInput> _items = [];
  bool _isSaving = false;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateYyyyMmDd ??
        DateTime.now().toIso8601String().split('T').first;
    _dateController = TextEditingController(text: initial);
    if (widget.planId != null) {
      _loadPlan();
    } else {
      _items.add(_PlanItemInput());
      _isLoading = false;
    }
  }

  Future<void> _loadPlan() async {
    final id = widget.planId!;
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    try {
      final plan = await ds.getById(id);
      if (!mounted) return;
      if (plan == null) {
        setState(() {
          _loadError = 'Không tìm thấy kế hoạch';
          _isLoading = false;
        });
        return;
      }
      final apiDate = plan.planDateYyyyMmDd ?? _ddMmYyyyToYyyyMmDd(plan.planDate);
      _dateController.text = apiDate;
      _items.clear();
      for (final it in plan.items) {
        _items.add(_PlanItemInput(
          productId: it.productId ?? '',
          productDisplay: it.productCode.isNotEmpty
              ? '${it.productCode} - ${it.productName}'
              : '',
          quantity: it.plannedQuantity,
        ));
      }
      if (_items.isEmpty) _items.add(_PlanItemInput());
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Lỗi tải kế hoạch: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final parts = _dateController.text.split('-');
    DateTime initialDate = DateTime.now();
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]) ?? initialDate.year;
      final month = int.tryParse(parts[1]) ?? initialDate.month;
      final day = int.tryParse(parts[2]) ?? initialDate.day;
      initialDate = DateTime(year, month, day);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      final yyyy = picked.year.toString().padLeft(4, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      _dateController.text = '$yyyy-$mm-$dd';
      setState(() {});
    }
  }

  Future<void> _pickProduct(int index) async {
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    final q = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Tìm sản phẩm'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(
              labelText: 'Mã hoặc tên SP',
            ),
            autofocus: true,
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
    if (q == null || q.trim().isEmpty || !mounted) return;
    final list = await ds.suggestProducts(q);
    if (!mounted) return;
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy sản phẩm')),
      );
      return;
    }
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn sản phẩm'),
        children: List.generate(list.length, (i) {
          final p = list[i];
          return ListTile(
            title: Text('${p.code} - ${p.name}'),
            onTap: () => Navigator.pop(ctx, i),
          );
        }),
      ),
    );
    if (chosen == null || !mounted) return;
    final p = list[chosen];
    setState(() {
      _items[index].productId = p.id;
      _items[index].productDisplay = '${p.code} - ${p.name}';
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final dateStr = _dateController.text.trim();
    if (dateStr.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày lập kế hoạch')),
      );
      return;
    }
    final validItems = _items
        .where((e) => e.productId.trim().isNotEmpty && e.quantity > 0)
        .toList();
    if (validItems.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập ít nhất một dòng sản phẩm hợp lệ')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final ds = ref.read(productionPlanRemoteDataSourceProvider);
    try {
      final itemsJson = <Map<String, dynamic>>[];
      for (var i = 0; i < validItems.length; i++) {
        final it = validItems[i];
        itemsJson.add({
          'productId': it.productId.trim(),
          'ordinal': i + 1,
          'plannedQuantity': it.quantity,
        });
      }
      ProductionPlanModel result;
      if (widget.planId != null) {
        result = await ds.update(widget.planId!, dateStr, itemsJson);
      } else {
        result = await ds.create(dateStr, itemsJson);
      }
      if (!mounted) return;
      ref.invalidate(productionPlanProvider);
      final msg = widget.planId != null
          ? (result.status == 'submitted'
              ? 'Đã lưu, kế hoạch chờ duyệt lại'
              : 'Đã cập nhật kế hoạch sản xuất')
          : 'Đã lưu kế hoạch sản xuất';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Lỗi khi lưu kế hoạch';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'] as String;
        }
      } else {
        msg = '$msg: $e';
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        title: widget.planId != null ? 'Sửa Kế hoạch Sản xuất' : 'Lập Kế hoạch Sản xuất',
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return AppScaffold(
        title: 'Sửa Kế hoạch Sản xuất',
        toolbarActions: [
          ToolbarButton(
            label: 'Quay lại',
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: widget.planId != null ? 'Sửa Kế hoạch Sản xuất' : 'Lập Kế hoạch Sản xuất',
      toolbarActions: [
        ToolbarButton(
          label: 'Quay lại',
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
        ToolbarButton(
          label: 'Lưu kế hoạch',
          icon: Icons.save,
          onPressed: _isSaving ? null : _save,
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày lập kế hoạch',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'YYYY-MM-DD',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        tooltip: 'Chọn ngày',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Danh sách sản phẩm',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${index + 1}.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.productDisplay.isEmpty
                                ? 'Chưa chọn SP'
                                : item.productDisplay,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => _pickProduct(index),
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Chọn sản phẩm'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        key: ValueKey('qty-$index-${item.productId}'),
                        decoration: const InputDecoration(
                          labelText: 'Số lượng',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: item.quantity > 0 ? '${item.quantity}' : '',
                        onChanged: (v) =>
                            item.quantity = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Xóa dòng',
                      onPressed: _items.length == 1
                          ? null
                          : () {
                              setState(() => _items.removeAt(index));
                            },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  setState(() => _items.add(_PlanItemInput()));
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm dòng'),
              ),
              const SizedBox(width: 12),
              if (_isSaving) const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
