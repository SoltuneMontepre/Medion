import 'package:flutter/material.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredients_repository.dart';

/// Dialog to create or edit an ingredient. [ingredient] null = create, non-null = edit.
Future<Ingredient?> showIngredientFormDialog(
  BuildContext context, {
  Ingredient? ingredient,
  required IngredientsRepository repository,
}) async {
  return showDialog<Ingredient?>(
    context: context,
    builder: (context) => _IngredientFormDialog(
      ingredient: ingredient,
      repository: repository,
    ),
  );
}

class _IngredientFormDialog extends StatefulWidget {
  const _IngredientFormDialog(
      {this.ingredient, required this.repository});

  final Ingredient? ingredient;
  final IngredientsRepository repository;

  @override
  State<_IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<_IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.ingredient;
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'kg');
    _descCtrl = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  IngredientMutationParams _getParams() {
    return IngredientMutationParams(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      unit: _unitCtrl.text.trim().isEmpty ? 'kg' : _unitCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final params = _getParams();
      Ingredient? result;
      if (widget.ingredient == null) {
        result = await widget.repository.createIngredient(params);
      } else {
        result =
            await widget.repository.updateIngredient(widget.ingredient!.id, params);
      }
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ingredient != null;
    return AlertDialog(
      title: Text(isEdit ? 'Sửa nguyên liệu' : 'Thêm nguyên liệu'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã nguyên liệu',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isEdit,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Mã là bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên nguyên liệu',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Tên là bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Đơn vị (kg, lít, ...)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
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
