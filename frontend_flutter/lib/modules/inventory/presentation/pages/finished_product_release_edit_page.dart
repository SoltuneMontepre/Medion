import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/datasources/finished_product_dispatch_remote_datasource_impl.dart';
import '../../domain/entities/finished_product_release.dart';
import '../providers/finished_product_release_provider.dart';

class _LineInput {
  String productId = '';
  String productDisplay = '';
  int quantity = 0;
  String lotNumber = '';
  String manufacturingDate = '';
  String expiryDate = '';
}

class FinishedProductReleaseEditPage extends ConsumerStatefulWidget {
  const FinishedProductReleaseEditPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<FinishedProductReleaseEditPage> createState() =>
      _FinishedProductReleaseEditPageState();
}

class _FinishedProductReleaseEditPageState
    extends ConsumerState<FinishedProductReleaseEditPage> {
  final _orderNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<_LineInput> _lines = [];
  final List<TextEditingController> _lotControllers = [];
  final List<TextEditingController> _mfgControllers = [];
  final List<TextEditingController> _expControllers = [];
  final List<TextEditingController> _qtyControllers = [];
  bool _isSaving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _orderNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    for (final c in _lotControllers) {
      c.dispose();
    }
    for (final c in _mfgControllers) {
      c.dispose();
    }
    for (final c in _expControllers) {
      c.dispose();
    }
    for (final c in _qtyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _fillFrom(FinishedProductRelease r) {
    _orderNumberController.text = r.orderNumber;
    _addressController.text = r.address;
    _phoneController.text = r.phone;
    _lines.clear();
    for (final c in _lotControllers) {
      c.dispose();
    }
    _lotControllers.clear();
    for (final c in _mfgControllers) {
      c.dispose();
    }
    _mfgControllers.clear();
    for (final c in _expControllers) {
      c.dispose();
    }
    _expControllers.clear();
    for (final c in _qtyControllers) {
      c.dispose();
    }
    _qtyControllers.clear();
    for (final line in r.lines) {
      _lines.add(_LineInput()
        ..productId = line.productId ?? ''
        ..productDisplay =
            '${line.productCode} - ${line.productName}'
        ..quantity = line.quantity
        ..lotNumber = line.batchNumber ?? ''
        ..manufacturingDate = line.manufacturingDate ?? ''
        ..expiryDate = line.expiryDate ?? '');
      _lotControllers.add(TextEditingController(text: line.batchNumber ?? ''));
      _mfgControllers
          .add(TextEditingController(text: line.manufacturingDate ?? ''));
      _expControllers.add(TextEditingController(text: line.expiryDate ?? ''));
      _qtyControllers.add(TextEditingController(text: '${line.quantity}'));
    }
    if (_lines.isEmpty) {
      _lines.add(_LineInput());
      _lotControllers.add(TextEditingController());
      _mfgControllers.add(TextEditingController());
      _expControllers.add(TextEditingController());
      _qtyControllers.add(TextEditingController());
    }
    _loaded = true;
  }

  Future<void> _pickProduct(int index) async {
    final ds = ref.read(finishedProductDispatchRemoteDataSourceProvider);
    final q = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Tìm sản phẩm'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(labelText: 'Mã hoặc tên SP'),
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
      _lines[index].productId = p.id;
      _lines[index].productDisplay = '${p.code} - ${p.name}';
    });
  }

  Future<void> _save() async {
    final orderNumber = _orderNumberController.text.trim();
    if (orderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số đơn hàng là bắt buộc')),
      );
      return;
    }
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ là bắt buộc')),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại là bắt buộc')),
      );
      return;
    }
    for (var i = 0; i < _lines.length; i++) {
      if (i < _lotControllers.length) {
        _lines[i].lotNumber = _lotControllers[i].text.trim();
        _lines[i].manufacturingDate = _mfgControllers[i].text.trim();
        _lines[i].expiryDate = _expControllers[i].text.trim();
      }
      if (i < _qtyControllers.length) {
        _lines[i].quantity = int.tryParse(_qtyControllers[i].text.trim()) ?? 0;
      }
    }
    final validLines = _lines
        .where((e) => e.productId.isNotEmpty && e.quantity > 0)
        .toList();
    if (validLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng thêm ít nhất một dòng sản phẩm hợp lệ')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final ds = ref.read(finishedProductDispatchRemoteDataSourceProvider);
    try {
      final items = <Map<String, dynamic>>[];
      for (var i = 0; i < validLines.length; i++) {
        final it = validLines[i];
        items.add({
          'productId': it.productId,
          'ordinal': i + 1,
          'quantity': it.quantity,
          'lotNumber': it.lotNumber.isEmpty ? null : it.lotNumber,
          'manufacturingDate':
              it.manufacturingDate.isEmpty ? null : it.manufacturingDate,
          'expiryDate': it.expiryDate.isEmpty ? null : it.expiryDate,
        });
      }
      await ds.update(
        widget.id,
        orderNumber: orderNumber,
        address: address,
        phone: phone,
        items: items,
      );
      if (!mounted) return;
      ref.invalidate(finishedProductReleasesProvider(null));
      ref.invalidate(finishedProductReleaseByIdProvider(widget.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật phiếu xuất kho')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
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
    final releaseAsync = ref.watch(finishedProductReleaseByIdProvider(widget.id));

    return AppScaffold(
      title: 'Sửa phiếu xuất kho Thành phẩm',
      toolbarActions: [
        ToolbarButton(
          label: 'Lưu',
          icon: Icons.save,
          onPressed: _isSaving ? null : _save,
        ),
      ],
      child: releaseAsync.when(
        data: (release) {
          if (release != null && !_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fillFrom(release);
              if (mounted) setState(() {});
            });
          }
          if (!_loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _orderNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Số đơn hàng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
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
        ...List.generate(_lines.length, (index) {
          final line = _lines[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 32, child: Text('${index + 1}.')),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              line.productDisplay.isEmpty
                                  ? 'Chưa chọn SP'
                                  : line.productDisplay,
                              style: const TextStyle(fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () => _pickProduct(index),
                              child: const Text('Chọn sản phẩm'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _lines.length == 1
                            ? null
                            : () {
                                setState(() {
                                  _lines.removeAt(index);
                                  if (index < _lotControllers.length) {
                                    _lotControllers[index].dispose();
                                    _lotControllers.removeAt(index);
                                    _mfgControllers[index].dispose();
                                    _mfgControllers.removeAt(index);
                                    _expControllers[index].dispose();
                                    _expControllers.removeAt(index);
                                    _qtyControllers[index].dispose();
                                    _qtyControllers.removeAt(index);
                                  }
                                });
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: index < _qtyControllers.length
                              ? _qtyControllers[index]
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Số',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: index < _lotControllers.length
                              ? _lotControllers[index]
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Số lô',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: TextField(
                          controller: index < _mfgControllers.length
                              ? _mfgControllers[index]
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'NSX (YYYY-MM-DD)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: TextField(
                          controller: index < _expControllers.length
                              ? _expControllers[index]
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'HSD (YYYY-MM-DD)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _lines.add(_LineInput());
                  _lotControllers.add(TextEditingController());
                  _mfgControllers.add(TextEditingController());
                  _expControllers.add(TextEditingController());
                  _qtyControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm dòng'),
            ),
            const SizedBox(width: 12),
            if (_isSaving) const CircularProgressIndicator(),
          ],
        ),
      ],
    );
  }
}
