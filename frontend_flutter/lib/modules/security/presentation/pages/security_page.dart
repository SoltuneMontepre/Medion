import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/repositories_impl/security_repository_impl.dart';
import '../providers/security_provider.dart';

/// Security info: user id, PIN status from API. Set/change PIN via dialogs.
class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(securityInfoProvider);

    return AppScaffold(
      title: 'Bảo mật',
      toolbarActions: [
        ToolbarButton(
          label: ref.watch(securityInfoProvider).valueOrNull?.transactionPinSet == true
              ? 'Đổi PIN'
              : 'Đặt PIN',
          icon: Icons.pin,
          onPressed: () => _openPinDialog(context, ref),
        ),
        ToolbarButton(
          label: 'Đặt lại mật khẩu',
          icon: Icons.lock_reset,
          onPressed: () {},
        ),
      ],
      child: infoAsync.when(
        data: (info) => Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 16,
            minWidth: 400,
            border: TableBorder.all(color: Colors.grey.shade300),
            headingRowColor:
                WidgetStateProperty.all(const Color(0xFFE3F2FD)),
            headingRowHeight: 48,
            dataRowHeight: 44,
            columns: const [
              DataColumn2(label: Text('Thuộc tính'), size: ColumnSize.M),
              DataColumn2(label: Text('Giá trị'), size: ColumnSize.L),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Mã người dùng')),
                DataCell(Text(info.userId.isEmpty ? '—' : info.userId)),
              ]),
              DataRow(
                color: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                cells: [
                  const DataCell(Text('PIN giao dịch')),
                  DataCell(Text(info.transactionPinSet ? 'Đã đặt' : 'Chưa đặt')),
                ],
              ),
              DataRow(cells: [
                const DataCell(Text('Đăng nhập lần cuối')),
                DataCell(Text(info.lastLogin)),
              ]),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  void _openPinDialog(BuildContext context, WidgetRef ref) {
    final hasPin = ref.read(securityInfoProvider).valueOrNull?.transactionPinSet ?? false;
    if (hasPin) {
      _showChangePinDialog(context, ref);
    } else {
      _showSetPinDialog(context, ref);
    }
  }

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt mã PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nhập mã PIN 4 chữ số để ký số đơn hàng.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Mã PIN',
                  hintText: '****',
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.length != 4) return 'Mã PIN phải gồm đúng 4 chữ số';
                  if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Chỉ được nhập số';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final pin = pinController.text;
              Navigator.of(ctx).pop();
              await _submitSetPin(context, ref, pin);
            },
            child: const Text('Đặt PIN'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, WidgetRef ref) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mã PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nhập mã PIN hiện tại và mã PIN mới (4 chữ số).',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: oldPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Mã PIN hiện tại',
                  hintText: '****',
                  counterText: '',
                ),
                validator: _validatePin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Mã PIN mới',
                  hintText: '****',
                  counterText: '',
                ),
                validator: _validatePin,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final oldPin = oldPinController.text;
              final newPin = newPinController.text;
              Navigator.of(ctx).pop();
              await _submitChangePin(context, ref, oldPin, newPin);
            },
            child: const Text('Đổi PIN'),
          ),
        ],
      ),
    );
  }

  String? _validatePin(String? v) {
    if (v == null || v.length != 4) return 'Mã PIN phải gồm đúng 4 chữ số';
    if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Chỉ được nhập số';
    return null;
  }

  Future<void> _submitSetPin(BuildContext context, WidgetRef ref, String pin) async {
    final repo = ref.read(securityRepositoryProvider);
    try {
      await repo.setPin(pin);
      ref.invalidate(securityInfoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thiết lập mã PIN thành công')),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        final msg = _errorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Future<void> _submitChangePin(
    BuildContext context,
    WidgetRef ref,
    String oldPin,
    String newPin,
  ) async {
    final repo = ref.read(securityRepositoryProvider);
    try {
      await repo.changePin(oldPin, newPin);
      ref.invalidate(securityInfoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mã PIN thành công')),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        final msg = _errorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
}
