import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../domain/entities/create_customer_params.dart';
import '../../domain/errors/customer_exceptions.dart';
import '../../domain/usecases/create_customer.dart';
import '../../data/repositories_impl/customers_repository_impl.dart';
import '../providers/customers_provider.dart';

/// Vietnamese mobile: 10 digits starting with 0 (e.g. 0901234567).
final _phoneRegex = RegExp(r'^0[0-9]{9}$');

class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _phoneFocus = FocusNode();

  String? _nameError;
  String? _addressError;
  String? _phoneError;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _nameError = null;
      _addressError = null;
      _phoneError = null;
    });
  }

  bool _validate() {
    _clearFieldErrors();
    var valid = true;
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Vui lòng nhập tên khách hàng.');
      valid = false;
    }
    if (address.isEmpty) {
      setState(() => _addressError = 'Vui lòng nhập địa chỉ.');
      valid = false;
    }
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Vui lòng nhập số điện thoại.');
      valid = false;
    } else if (!_phoneRegex.hasMatch(phone)) {
      setState(() => _phoneError = 'Số điện thoại không hợp lệ.');
      valid = false;
    }
    return valid;
  }

  Future<void> _onSave() async {
    if (!_validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(customersRepositoryProvider);
      final useCase = CreateCustomer(repository);
      await useCase(CreateCustomerParams(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      ));
      if (!mounted) return;
      ref.invalidate(customersProvider(1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo khách hàng thành công')),
      );
      context.go('/customers');
    } on CustomerDuplicatePhoneException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _phoneError = e.message ??
            'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _onCancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hủy tạo khách hàng mới',
      message:
          'Bạn có chắc chắn muốn hủy tạo khách hàng mới? Mọi thông tin đã nhập sẽ không được lưu.',
      cancelLabel: 'Hủy bỏ',
      confirmLabel: 'Đồng ý',
    );
    if (ok && mounted) {
      context.go('/customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Thông tin khách hàng mới',
      toolbarActions: [
        ToolbarButton(
          label: 'Lưu',
          icon: Icons.save,
          onPressed: _saving ? null : _onSave,
        ),
        ToolbarButton(
          label: 'Hủy tạo khách hàng mới',
          icon: Icons.cancel_outlined,
          onPressed: _saving ? null : _onCancel,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    labelText: 'Tên khách hàng',
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  focusNode: _addressFocus,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    errorText: _addressError,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '0901234567',
                    errorText: _phoneError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSave(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
