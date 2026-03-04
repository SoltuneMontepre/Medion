import 'package:flutter/material.dart';

import '../../domain/entities/create_customer_params.dart';
import '../../domain/entities/customer.dart';
import '../../domain/errors/customer_exceptions.dart';
import '../../domain/repositories/customers_repository.dart';

/// Vietnamese mobile: 10 digits starting with 0 (e.g. 0901234567).
final _phoneRegex = RegExp(r'^0[0-9]{9}$');

/// Dialog to edit a customer. [customer] is required (edit only).
Future<Customer?> showCustomerFormDialog(
  BuildContext context, {
  required Customer customer,
  required CustomersRepository repository,
}) async {
  return showDialog<Customer?>(
    context: context,
    builder: (context) => _CustomerFormDialog(
      customer: customer,
      repository: repository,
    ),
  );
}

class _CustomerFormDialog extends StatefulWidget {
  const _CustomerFormDialog({
    required this.customer,
    required this.repository,
  });

  final Customer customer;
  final CustomersRepository repository;

  @override
  State<_CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<_CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer.name);
    _addressCtrl = TextEditingController(text: widget.customer.address);
    _phoneCtrl = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên khách hàng.');
      return;
    }
    if (address.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập địa chỉ.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập số điện thoại.');
      return;
    }
    if (!_phoneRegex.hasMatch(phone)) {
      setState(() => _errorMessage = 'Số điện thoại không hợp lệ (10 số, bắt đầu 0).');
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await widget.repository.updateCustomer(
        widget.customer.id,
        CreateCustomerParams(name: name, address: address, phone: phone),
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on CustomerDuplicatePhoneException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = e.message ?? 'Số điện thoại đã tồn tại.';
      });
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
    return AlertDialog(
      title: const Text('Sửa khách hàng'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Mã: ${widget.customer.code}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên khách hàng *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    hintText: '0901234567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
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
              : const Text('Cập nhật'),
        ),
      ],
    );
  }
}
