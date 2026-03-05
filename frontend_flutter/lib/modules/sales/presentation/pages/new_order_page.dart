import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../data/datasources/sales_remote_datasource.dart';
import '../../data/datasources/sales_remote_datasource_impl.dart';
import '../../data/models/product_suggest_model.dart';
import '../../../customers/data/datasources/customers_remote_datasource.dart';
import '../../../customers/data/datasources/customers_remote_datasource_impl.dart';
import '../../../customers/data/models/customer_model.dart';
import '../providers/sales_provider.dart';

/// One product row in the order (local state).
class _ProductRow {
  _ProductRow({this.stt = 1}) : quantityController = TextEditingController();
  int stt;
  ProductSuggestModel? product;
  final TextEditingController quantityController;
  String? quantityError;
  bool get quantityValid {
    final n = int.tryParse(quantityController.text.trim());
    return n != null && n > 0;
  }
}

class NewOrderPage extends ConsumerStatefulWidget {
  const NewOrderPage({super.key});

  @override
  ConsumerState<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends ConsumerState<NewOrderPage> {
  final _customerSearchKey = GlobalKey<_CustomerSearchFieldState>();

  String _customerCode = '';
  String _customerName = '';
  String _customerAddress = '';
  String _customerPhone = '';
  CustomerModel? _selectedCustomer;
  bool _customerHasOrderToday = false;
  String? _existingOrderId;
  String _nextOrderNumber = '';
  bool _productSectionEnabled = false;
  bool _checkingCustomerOrder = false;
  bool _saving = false;

  final List<_ProductRow> _rows = [];
  bool _saveEnabled = false;

  late final CustomersRemoteDataSource _customersDs;
  late final SalesRemoteDataSource _salesDs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerSearchKey.currentState?.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _customersDs = ref.read(customersRemoteDataSourceProvider);
    _salesDs = ref.read(salesRemoteDataSourceProvider);
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.quantityController.dispose();
    }
    super.dispose();
  }

  String get _nowFormatted {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _updateSaveEnabled() {
    if (!_productSectionEnabled) {
      setState(() => _saveEnabled = false);
      return;
    }
    final valid =
        _rows.isNotEmpty &&
        _rows.every((r) => r.product != null && r.quantityValid) &&
        _rows.every((r) => r.quantityError == null);
    setState(() => _saveEnabled = valid);
  }

  String? _apiMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  void _addProductRow() {
    setState(() {
      _rows.add(_ProductRow(stt: _rows.length + 1));
      _updateSaveEnabled();
    });
  }

  void _removeProductRow(int index) {
    if (index < 0 || index >= _rows.length) return;
    setState(() {
      _rows[index].quantityController.dispose();
      _rows.removeAt(index);
      for (var i = 0; i < _rows.length; i++) _rows[i].stt = i + 1;
      _updateSaveEnabled();
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomer = null;
      _customerCode = '';
      _customerName = '';
      _customerAddress = '';
      _customerPhone = '';
      _customerHasOrderToday = false;
      _existingOrderId = null;
      _nextOrderNumber = '';
      _productSectionEnabled = false;
      _checkingCustomerOrder = false;
      for (final r in _rows) r.quantityController.dispose();
      _rows.clear();
      _saveEnabled = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerSearchKey.currentState?.clear();
      _customerSearchKey.currentState?.requestFocus();
    });
  }

  void _onCustomerSelected(CustomerModel c) {
    // Show placeholder state immediately while we fetch full data
    setState(() {
      _selectedCustomer = c;
      _customerCode = c.code;
      _customerName = c.name;
      _customerAddress = c.address;
      _customerPhone = c.phone;
      _customerHasOrderToday = false;
      _existingOrderId = null;
      _nextOrderNumber = '';
      _productSectionEnabled = false;
      _checkingCustomerOrder = true;
    });
    _fetchFullCustomerAndCheck(c.id);
  }

  Future<void> _fetchFullCustomerAndCheck(String customerId) async {
    try {
      final full = await _customersDs.getCustomerById(customerId);
      if (!mounted) return;
      setState(() {
        _selectedCustomer = full;
        _customerCode = full.code;
        _customerName = full.name;
        _customerAddress = full.address;
        _customerPhone = full.phone;
      });
    } catch (_) {
      // Tolerate failure — keep whatever the suggest response gave us
    }
    _checkCustomerOrderToday(customerId);
  }

  Future<void> _checkCustomerOrderToday(String customerId) async {
    if (mounted) setState(() => _checkingCustomerOrder = true);
    try {
      final r = await _salesDs.checkCustomerOrderToday(customerId);
      if (!mounted) return;
      setState(() {
        _customerHasOrderToday = r.hasOrderToday;
        _existingOrderId = r.existingOrderId;
        _nextOrderNumber = r.nextOrderNumber ?? '';
        _productSectionEnabled = !r.hasOrderToday;
        _checkingCustomerOrder = false;
        if (_productSectionEnabled && _rows.isEmpty)
          _rows.add(_ProductRow(stt: 1));
      });
      _updateSaveEnabled();
    } catch (_) {
      if (mounted) {
        setState(() {
          _customerHasOrderToday = false;
          _productSectionEnabled = true;
          _nextOrderNumber = '';
          _checkingCustomerOrder = false;
          if (_rows.isEmpty) _rows.add(_ProductRow(stt: 1));
        });
        _updateSaveEnabled();
      }
    }
  }

  void _openExistingOrder() {
    if (_existingOrderId == null) return;
    context.push('/customers/orders/$_existingOrderId');
  }

  Future<void> _saveOrder() async {
    if (!_saveEnabled || _selectedCustomer == null || _saving) return;
    final items = <OrderItemRequest>[];
    for (final r in _rows) {
      if (r.product == null || !r.quantityValid) continue;
      items.add(
        OrderItemRequest(
          productId: r.product!.id,
          quantity: int.parse(r.quantityController.text.trim()),
        ),
      );
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại thông tin sản phẩm'),
        ),
      );
      return;
    }

    final result = await showDialog<_ConfirmAndPinResult>(
      context: context,
      builder: (ctx) => _ConfirmAndPinDialog(
        customerName: _customerName,
        customerCode: _customerCode,
        items: _rows
            .where((r) => r.product != null && r.quantityValid)
            .map(
              (r) => MapEntry(
                r.product!,
                int.parse(r.quantityController.text.trim()),
              ),
            )
            .toList(),
      ),
    );
    if (result == null || !mounted) return;
    final pin = result.pin;
    if (pin.isEmpty) return;

    setState(() => _saving = true);
    try {
      final order = await _salesDs.createOrder(
        customerId: _selectedCustomer!.id,
        items: items,
        pin: pin,
      );
      if (!mounted) return;
      ref.invalidate(salesOrdersProvider(1));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lưu và ký đơn hàng thành công'),
          backgroundColor: Colors.green,
          action: order.id.isNotEmpty
              ? SnackBarAction(
                  label: 'Xem đơn',
                  textColor: Colors.white,
                  onPressed: () => context.go('/customers/orders/${order.id}'),
                )
              : null,
        ),
      );
      context.go('/customers/orders');
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode ?? 0;
      String msg =
          status == 409 || e.toString().contains('Conflict')
              ? 'Khách hàng này đã có đơn hàng hôm nay'
              : (status == 400 || e.toString().contains('PIN')
                    ? 'Ký số không thành công, vui lòng kiểm tra lại thiết bị hoặc mã PIN'
                    : _apiMessage(e) ?? 'Có lỗi xảy ra, vui lòng thử lại sau');
      if (status >= 500 && status < 600) {
        msg = '$msg Nếu đơn đã được tạo, vui lòng kiểm tra danh sách đơn hàng.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final msg =
          e.toString().contains('409') || e.toString().contains('Conflict')
              ? 'Khách hàng này đã có đơn hàng hôm nay'
              : (e.toString().contains('400') || e.toString().contains('PIN')
                    ? 'Ký số không thành công, vui lòng kiểm tra lại thiết bị hoặc mã PIN'
                    : 'Có lỗi xảy ra, vui lòng thử lại sau');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step1Done = _selectedCustomer != null && !_checkingCustomerOrder;
    final step2Done =
        _rows.isNotEmpty &&
        _rows.every((r) => r.product != null && r.quantityValid) &&
        _rows.every((r) => r.quantityError == null);
    return AppScaffold(
      title: 'Đơn đặt hàng mới',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(step1Done: step1Done, step2Done: step2Done),
            const SizedBox(height: 16),
            const Text(
              'Lưu ý: Mỗi khách hàng chỉ tạo 1 đơn đặt hàng trong ngày.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _buildCustomerSection(),
            const SizedBox(height: 24),
            _buildProductSection(),
            const SizedBox(height: 24),
            _buildSignatureAndSave(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool step1Done,
    required bool step2Done,
  }) {
    return Row(
      children: [
        _StepChip(
          label: '1. Chọn khách hàng',
          done: step1Done,
          active: _selectedCustomer == null,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
        ),
        _StepChip(
          label: '2. Thêm sản phẩm',
          done: step2Done,
          active: step1Done && !step2Done,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
        ),
        _StepChip(label: '3. Xác nhận & Ký số', done: false, active: step2Done),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Thông tin khách hàng',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_selectedCustomer != null) ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _clearCustomer,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Đổi khách'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _CustomerSearchField(
                    key: _customerSearchKey,
                    onSelected: _onCustomerSelected,
                    customersDs: _customersDs,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _ReadOnlyField('Mã khách hàng', _customerCode)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ReadOnlyField('Tên khách hàng', _customerName),
                ),
                const SizedBox(width: 16),
                Expanded(child: _ReadOnlyField('Địa chỉ', _customerAddress)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ReadOnlyField('Số điện thoại', _customerPhone),
                ),
                const SizedBox(width: 16),
                Expanded(child: _ReadOnlyField('Ngày tạo đơn', _nowFormatted)),
              ],
            ),
            const SizedBox(height: 8),
            _ReadOnlyField('Số đơn hàng', _nextOrderNumber),
            if (_customerHasOrderToday) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Khách hàng này đã có đơn hàng hôm nay',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _existingOrderId != null
                        ? _openExistingOrder
                        : null,
                    child: const Text('Xem đơn hàng của khách'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách sản phẩm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_checkingCustomerOrder)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: _productSectionEnabled ? _addProductRow : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm sản phẩm'),
                  ),
              ],
            ),
            if (_checkingCustomerOrder)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Đang kiểm tra đơn hàng trong ngày...',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            if (_rows.isEmpty && !_checkingCustomerOrder)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    _productSectionEnabled
                        ? 'Nhấn "Thêm sản phẩm" để thêm dòng.'
                        : 'Chọn khách hàng để thêm sản phẩm.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFE3F2FD),
                  ),
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Chọn SP')),
                    DataColumn(label: Text('MÃ SP')),
                    DataColumn(label: Text('TÊN SẢN PHẨM')),
                    DataColumn(label: Text('QUY CÁCH')),
                    DataColumn(label: Text('DẠNG SP')),
                    DataColumn(label: Text('DẠNG ĐÓNG GÓI')),
                    DataColumn(label: Text('SỐ LƯỢNG')),
                    DataColumn(label: Text('')),
                  ],
                  rows: _rows.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final r = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('${r.stt}')),
                        DataCell(
                          (_productSectionEnabled
                              ? _ProductSearchCell(
                                  salesDs: _salesDs,
                                  onProductSelected: (p) {
                                    setState(() {
                                      r.product = p;
                                      _updateSaveEnabled();
                                    });
                                  },
                                )
                              : const SizedBox.shrink()),
                        ),
                        DataCell(Text(r.product?.code ?? '')),
                        DataCell(Text(r.product?.name ?? '')),
                        DataCell(Text(r.product?.specification ?? '')),
                        DataCell(Text(r.product?.productType ?? '')),
                        DataCell(Text(r.product?.packagingType ?? '')),
                        DataCell(
                          (_productSectionEnabled
                              ? _QuantityCell(
                                  controller: r.quantityController,
                                  error: r.quantityError,
                                  onChanged: (v) {
                                    setState(() {
                                      final n = int.tryParse(v.trim());
                                      if (v.trim().isEmpty ||
                                          n == null ||
                                          n <= 0) {
                                        r.quantityError =
                                            'Số lượng sản phẩm không hợp lệ, vui lòng nhập lại số nguyên dương';
                                      } else {
                                        r.quantityError = null;
                                      }
                                      _updateSaveEnabled();
                                    });
                                  },
                                )
                              : const Text('')),
                        ),
                        DataCell(
                          _productSectionEnabled && _rows.length > 1
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () => _removeProductRow(idx),
                                  tooltip: 'Xóa dòng',
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureAndSave() {
    return Row(
      children: [
        const Text('Nhân viên phòng Kinh doanh – Ký số'),
        const Spacer(),
        FilledButton(
          onPressed: (_saveEnabled && !_saving) ? _saveOrder : null,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Lưu Đơn'),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFFE8E0F0)
            : active
            ? const Color(0xFFE3F2FD)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            const Icon(Icons.check_circle, color: Color(0xFF5E35B1), size: 18)
          else
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: active ? const Color(0xFF1976D2) : Colors.grey,
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active || done ? FontWeight.w600 : FontWeight.normal,
              color: done
                  ? const Color(0xFF5E35B1)
                  : (active ? const Color(0xFF1976D2) : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityCell extends StatelessWidget {
  const _QuantityCell({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: onChanged,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomerSearchField extends StatefulWidget {
  const _CustomerSearchField({
    super.key,
    required this.onSelected,
    required this.customersDs,
  });

  final void Function(CustomerModel) onSelected;
  final CustomersRemoteDataSource customersDs;

  @override
  State<_CustomerSearchField> createState() => _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends State<_CustomerSearchField> {
  TextEditingController? _fieldController;
  FocusNode? _fieldFocusNode;

  void clear() => _fieldController?.clear();
  void requestFocus() => _fieldFocusNode?.requestFocus();

  @override
  Widget build(BuildContext context) {
    return Autocomplete<CustomerModel>(
      displayStringForOption: (c) => '${c.code} - ${c.name}',
      optionsBuilder: (TextEditingValue value) async {
        final q = value.text.trim();
        if (q.isEmpty) return const [];
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return const [];
        try {
          return await widget.customersDs.suggestCustomers(q);
        } catch (_) {
          return const [];
        }
      },
      onSelected: (CustomerModel c) => widget.onSelected(c),
      fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
        _fieldController = controller;
        _fieldFocusNode = focusNode;
        return TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tìm Mã / Tên / SĐT khách hàng',
            border: OutlineInputBorder(),
            hintText: 'Nhập mã, tên hoặc SĐT...',
          ),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 500),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final c = options.elementAt(i);
                  return ListTile(
                    title: Text(
                      '${c.code} - ${c.name} - ${c.phone} - ${c.address}',
                    ),
                    onTap: () => onSelected(c),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductSearchCell extends StatefulWidget {
  const _ProductSearchCell({
    required this.salesDs,
    required this.onProductSelected,
  });

  final SalesRemoteDataSource salesDs;
  final void Function(ProductSuggestModel) onProductSelected;

  @override
  State<_ProductSearchCell> createState() => _ProductSearchCellState();
}

class _ProductSearchCellState extends State<_ProductSearchCell> {
  final _controller = TextEditingController();
  List<ProductSuggestModel> _suggestions = [];
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  void _onQueryChanged(String q) async {
    if (q.trim().isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      final list = await widget.salesDs.fetchProductSuggest(q);
      if (!mounted) return;
      setState(() => _suggestions = list);
      _showOverlay();
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    }
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 400,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 40),
          child: Material(
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _suggestions.isEmpty
                    ? [
                        const ListTile(
                          title: Text('Không tìm thấy sản phẩm phù hợp'),
                        ),
                      ]
                    : _suggestions
                          .map(
                            (p) => ListTile(
                              title: Text(
                                '${p.code} - ${p.name} - ${p.specification} - ${p.productType} - ${p.packagingType}',
                              ),
                              onTap: () {
                                widget.onProductSelected(p);
                                _controller.text = p.code;
                                _removeOverlay();
                                setState(() => _suggestions = []);
                              },
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlay!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Mã / Tên SP',
          isDense: true,
          border: OutlineInputBorder(),
        ),
        onChanged: _onQueryChanged,
      ),
    );
  }
}

class _ConfirmAndPinResult {
  const _ConfirmAndPinResult(this.pin);
  final String pin;
}

class _ConfirmAndPinDialog extends StatefulWidget {
  const _ConfirmAndPinDialog({
    required this.customerName,
    required this.customerCode,
    required this.items,
  });

  final String customerName;
  final String customerCode;
  final List<MapEntry<ProductSuggestModel, int>> items;

  @override
  State<_ConfirmAndPinDialog> createState() => _ConfirmAndPinDialogState();
}

class _ConfirmAndPinDialogState extends State<_ConfirmAndPinDialog> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận đơn hàng & Ký số'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: ${widget.customerCode} - ${widget.customerName}'),
            const SizedBox(height: 12),
            const Text(
              'Danh sách sản phẩm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...widget.items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${e.key.code} ${e.key.name} x ${e.value}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhập mã PIN để ký số và lưu đơn:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Mã PIN',
                border: OutlineInputBorder(),
                hintText: 'Nhập mã PIN',
              ),
              onSubmitted: (_) {
                if (_pinController.text.trim().isNotEmpty) {
                  Navigator.of(
                    context,
                  ).pop(_ConfirmAndPinResult(_pinController.text.trim()));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final pin = _pinController.text.trim();
            if (pin.isEmpty) return;
            Navigator.of(context).pop(_ConfirmAndPinResult(pin));
          },
          child: const Text('Ký số & Lưu đơn'),
        ),
      ],
    );
  }
}
