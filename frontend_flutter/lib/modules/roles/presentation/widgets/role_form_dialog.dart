import 'package:flutter/material.dart';

import '../../domain/entities/role.dart';
import '../../domain/repositories/roles_repository.dart';

Future<Role?> showRoleFormDialog(
  BuildContext context, {
  Role? role,
  required RolesRepository repository,
  required List<Role> allRoles,
}) async {
  return showDialog<Role?>(
    context: context,
    builder: (context) => _RoleFormDialog(
      role: role,
      repository: repository,
      allRoles: allRoles,
    ),
  );
}

class _RoleFormDialog extends StatefulWidget {
  const _RoleFormDialog({
    this.role,
    required this.repository,
    required this.allRoles,
  });

  final Role? role;
  final RolesRepository repository;
  final List<Role> allRoles;

  @override
  State<_RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<_RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String? _selectedParentId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final r = widget.role;
    _codeCtrl = TextEditingController(text: r?.code ?? '');
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _selectedParentId = r?.parentRoleId;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  RoleMutationParams _getParams() {
    return RoleMutationParams(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      parentRoleId: _selectedParentId?.isEmpty ?? true ? null : _selectedParentId,
    );
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final params = _getParams();
      Role result;
      if (widget.role == null) {
        result = await widget.repository.createRole(params);
      } else {
        result = await widget.repository.updateRole(widget.role!.id, params);
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
    final isEdit = widget.role != null;
    final parentOptions = widget.allRoles
        .where((r) => r.id != widget.role?.id)
        .toList();

    return AlertDialog(
      title: Text(isEdit ? 'Sửa vai trò' : 'Thêm vai trò'),
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
                    labelText: 'Mã vai trò *',
                    border: OutlineInputBorder(),
                    hintText: 'sale_admin',
                  ),
                  readOnly: isEdit,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Nhập mã vai trò' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên vai trò *',
                    border: OutlineInputBorder(),
                    hintText: 'Sale Admin',
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Nhập tên vai trò' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _selectedParentId,
                  decoration: const InputDecoration(
                    labelText: 'Vai trò cha (phân cấp)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('— Không —'),
                    ),
                    ...parentOptions.map((r) => DropdownMenuItem<String>(
                          value: r.id,
                          child: Text('${r.code} — ${r.name}'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _selectedParentId = v),
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
