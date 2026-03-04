import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

/// Dialog to create or edit a product. [product] null = create, non-null = edit.
Future<Product?> showProductFormDialog(
  BuildContext context, {
  Product? product,
  required ProductsRepository repository,
}) async {
  return showDialog<Product?>(
    context: context,
    builder: (context) => _ProductFormDialog(
      product: product,
      repository: repository,
    ),
  );
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({this.product, required this.repository});

  final Product? product;
  final ProductsRepository repository;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _packageSizeCtrl;
  late final TextEditingController _packageUnitCtrl;
  late final TextEditingController _productTypeCtrl;
  late final TextEditingController _packagingTypeCtrl;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _packageSizeCtrl = TextEditingController(text: p?.packageSize ?? '');
    _packageUnitCtrl = TextEditingController(text: p?.packageUnit ?? '');
    _productTypeCtrl = TextEditingController(text: p?.productType ?? '');
    _packagingTypeCtrl = TextEditingController(text: p?.packagingType ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _packageSizeCtrl.dispose();
    _packageUnitCtrl.dispose();
    _productTypeCtrl.dispose();
    _packagingTypeCtrl.dispose();
    super.dispose();
  }

  ProductMutationParams _getParams() {
    return ProductMutationParams(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      packageSize: _packageSizeCtrl.text.trim().isEmpty ? '-' : _packageSizeCtrl.text.trim(),
      packageUnit: _packageUnitCtrl.text.trim().isEmpty ? '-' : _packageUnitCtrl.text.trim(),
      productType: _productTypeCtrl.text.trim().isEmpty ? '-' : _productTypeCtrl.text.trim(),
      packagingType: _packagingTypeCtrl.text.trim().isEmpty ? '-' : _packagingTypeCtrl.text.trim(),
    );
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final params = _getParams();
      Product result;
      if (widget.product == null) {
        result = await widget.repository.createProduct(params);
      } else {
        result = await widget.repository.updateProduct(widget.product!.id, params);
      }
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return AlertDialog(
      title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã SP *',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isEdit,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Nhập mã sản phẩm' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Nhập tên sản phẩm' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _packageSizeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quy cách (số)',
                          border: OutlineInputBorder(),
                          hintText: '100',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _packageUnitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị',
                          border: OutlineInputBorder(),
                          hintText: 'gr, ml',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _productTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dạng SP',
                    border: OutlineInputBorder(),
                    hintText: 'Bột uống, Dung dịch...',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _packagingTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dạng đóng gói',
                    border: OutlineInputBorder(),
                    hintText: 'Gói, Chai',
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Cập nhật' : 'Tạo'),
        ),
      ],
    );
  }
}
