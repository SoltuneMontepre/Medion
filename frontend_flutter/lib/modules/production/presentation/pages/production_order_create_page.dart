import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/production_plan_remote_datasource_impl.dart';
import '../../data/datasources/production_remote_datasource_impl.dart';
import '../providers/production_provider.dart';

/// Lập lệnh sản xuất — 1 lệnh = 1 sản phẩm (theo quy định GMP).
class ProductionOrderCreatePage extends ConsumerStatefulWidget {
  const ProductionOrderCreatePage({
    super.key,
    this.planItemId,
    this.productId,
    this.productDisplay,
    this.plannedQuantity,
  });

  /// Optional: pre-fill from approved plan item.
  final String? planItemId;
  final String? productId;
  final String? productDisplay;
  final int? plannedQuantity;

  @override
  ConsumerState<ProductionOrderCreatePage> createState() =>
      _ProductionOrderCreatePageState();
}

class _ProductionOrderCreatePageState
    extends ConsumerState<ProductionOrderCreatePage> {
  String _productId = '';
  String _productDisplay = '';
  final _batchNumberController = TextEditingController();
  final _productionDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _batchSizeController = TextEditingController(text: '200');
  final _qtySpec1Controller = TextEditingController(text: '0');
  final _qtySpec2Controller = TextEditingController(text: '0');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _productId = widget.productId!;
      _productDisplay = widget.productDisplay ?? '';
    }
    final now = DateTime.now();
    _productionDateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final exp = now.add(const Duration(days: 730));
    _expiryDateController.text =
        '${exp.year}-${exp.month.toString().padLeft(2, '0')}-${exp.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _productionDateController.dispose();
    _expiryDateController.dispose();
    _batchSizeController.dispose();
    _qtySpec1Controller.dispose();
    _qtySpec2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickProduct() async {
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
        title: const Text('Chọn sản phẩm (1 lệnh = 1 sản phẩm)'),
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
      _productId = p.id;
      _productDisplay = '${p.code} - ${p.name}';
    });
  }

  Future<void> _pickDate(TextEditingController c) async {
    final parts = c.text.split('-');
    DateTime initial = DateTime.now();
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        initial = DateTime(y, m, d);
      }
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      c.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_productId.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm')),
      );
      return;
    }
    final batch = _batchNumberController.text.trim();
    if (batch.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Số lô là bắt buộc')),
      );
      return;
    }
    final prodDate = _productionDateController.text.trim();
    final expDate = _expiryDateController.text.trim();
    if (prodDate.isEmpty || expDate.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ngày sản xuất và hạn sử dụng là bắt buộc')),
      );
      return;
    }
    final batchSize = double.tryParse(_batchSizeController.text);
    if (batchSize == null || batchSize <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Cỡ lô (lít) phải > 0')),
      );
      return;
    }
    final q1 = int.tryParse(_qtySpec1Controller.text) ?? 0;
    final q2 = int.tryParse(_qtySpec2Controller.text) ?? 0;
    if (q1 < 0 || q2 < 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Số lượng không hợp lệ')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final ds = ref.read(productionRemoteDataSourceProvider);
    try {
      await ds.create({
        'productId': _productId,
        'batchNumber': batch,
        'productionDate': prodDate,
        'expiryDate': expDate,
        'batchSizeLit': batchSize,
        'quantitySpec1': q1,
        'quantitySpec2': q2,
        if (widget.planItemId != null) 'planItemId': widget.planItemId,
      });
      if (!mounted) return;
      ref.invalidate(productionOrdersProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã tạo lệnh sản xuất')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lập lệnh sản xuất',
      toolbarActions: [
        ToolbarButton(
          label: 'Quay lại',
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
        ToolbarButton(
          label: 'Lưu',
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
                    'Thông tin sản phẩm (1 lệnh = 1 sản phẩm)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _productDisplay.isEmpty
                              ? 'Chưa chọn sản phẩm'
                              : _productDisplay,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickProduct,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Chọn sản phẩm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số lô, ngày sản xuất, hạn sử dụng',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _batchNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Số lô',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _productionDateController,
                          decoration: const InputDecoration(
                            labelText: 'Ngày SX (YYYY-MM-DD)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_productionDateController),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: 'Hạn sử dụng',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _pickDate(_expiryDateController),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cỡ lô và số lượng theo quy cách',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _batchSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Cỡ lô (lít)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _qtySpec1Controller,
                          decoration: const InputDecoration(
                            labelText: 'SL QC1 (chai)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _qtySpec2Controller,
                          decoration: const InputDecoration(
                            labelText: 'SL QC2 (chai)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
