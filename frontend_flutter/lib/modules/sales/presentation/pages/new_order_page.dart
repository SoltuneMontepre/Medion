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
  final _customerQueryFocus = FocusNode();
  final _customerSearchController = TextEditingController();
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

  final List<_ProductRow> _rows = [];
  bool _saveEnabled = false;

  late final CustomersRemoteDataSource _customersDs;
  late final SalesRemoteDataSource _salesDs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_customerQueryFocus);
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
    _customerQueryFocus.dispose();
    _customerSearchController.dispose();
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
    final valid = _rows.isNotEmpty &&
        _rows.every((r) => r.product != null && r.quantityValid) &&
        _rows.every((r) => r.quantityError == null);
    setState(() => _saveEnabled = valid);
  }

  void _addProductRow() {
    setState(() {
      _rows.add(_ProductRow(stt: _rows.length + 1));
      _updateSaveEnabled();
    });
  }

  void _onCustomerSelected(CustomerModel c) {
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
    });
    _checkCustomerOrderToday(c.id);
  }

  Future<void> _checkCustomerOrderToday(String customerId) async {
    try {
      final r = await _salesDs.checkCustomerOrderToday(customerId);
      if (!mounted) return;
      setState(() {
        _customerHasOrderToday = r.hasOrderToday;
        _existingOrderId = r.existingOrderId;
        _nextOrderNumber = r.nextOrderNumber ?? '';
        _productSectionEnabled = !r.hasOrderToday;
      });
      _updateSaveEnabled();
    } catch (_) {
      if (mounted) {
        setState(() {
          _customerHasOrderToday = false;
          _productSectionEnabled = true;
          _nextOrderNumber = '';
        });
        _updateSaveEnabled();
      }
    }
  }

  void _openExistingOrder() {
    if (_existingOrderId == null) return;
    context.push('/sales/orders/$_existingOrderId');
  }

  Future<void> _saveOrder() async {
    if (!_saveEnabled || _selectedCustomer == null) return;
    final items = <OrderItemRequest>[];
    for (final r in _rows) {
      if (r.product == null || !r.quantityValid) continue;
      items.add(OrderItemRequest(
        productId: r.product!.id,
        quantity: int.parse(r.quantityController.text.trim()),
      ));
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin sản phẩm')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmOrderDialog(
        customerName: _customerName,
        customerCode: _customerCode,
        items: _rows
            .where((r) => r.product != null && r.quantityValid)
            .map((r) => MapEntry(r.product!, int.parse(r.quantityController.text.trim())))
            .toList(),
      ),
    );
    if (confirmed != true || !mounted) return;

    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => _PinDialog(),
    );
    if (pin == null || pin.isEmpty || !mounted) return;

    try {
      await _salesDs.createOrder(
        customerId: _selectedCustomer!.id,
        items: items,
        pin: pin,
      );
      if (!mounted) return;
      ref.invalidate(salesOrdersProvider(1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu và ký đơn hàng thành công'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/sales');
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('409') || e.toString().contains('Conflict')
          ? 'Khách hàng này đã có đơn hàng hôm nay'
          : (e.toString().contains('400') || e.toString().contains('PIN')
              ? 'Ký số không thành công, vui lòng kiểm tra lại thiết bị hoặc mã PIN'
              : 'Có lỗi xảy ra, vui lòng thử lại sau');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Đơn đặt hàng mới',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lưu ý: Mỗi khách hàng chỉ tạo 1 Đơn đặt hàng thôi',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin khách hàng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _CustomerSearchField(
                    key: _customerSearchKey,
                    focusNode: _customerQueryFocus,
                    controller: _customerSearchController,
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
                Expanded(child: _ReadOnlyField('Tên khách hàng', _customerName)),
                const SizedBox(width: 16),
                Expanded(child: _ReadOnlyField('Địa chỉ', _customerAddress)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _ReadOnlyField('Số điện thoại', _customerPhone)),
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
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Khách hàng này đã có đơn hàng hôm nay',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _existingOrderId != null ? _openExistingOrder : null,
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
                Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleMedium),
                FilledButton.icon(
                  onPressed: _productSectionEnabled ? _addProductRow : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm sản phẩm'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Chưa thêm sản phẩm. Nhấn "Thêm sản phẩm" để thêm dòng.'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Chọn SP')),
                    DataColumn(label: Text('MÃ SP')),
                    DataColumn(label: Text('TÊN SẢN PHẨM')),
                    DataColumn(label: Text('QUY CÁCH')),
                    DataColumn(label: Text('DẠNG SP')),
                    DataColumn(label: Text('DẠNG ĐÓNG GÓI')),
                    DataColumn(label: Text('SỐ LƯỢNG')),
                  ],
                  rows: _rows.asMap().entries.map((entry) {
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
                                      if (v.trim().isEmpty || n == null || n <= 0) {
                                        r.quantityError = 'Số lượng sản phẩm không hợp lệ, vui lòng nhập lại số nguyên dương';
                                      } else {
                                        r.quantityError = null;
                                      }
                                      _updateSaveEnabled();
                                    });
                                  },
                                )
                              : const Text('')),
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
          onPressed: _saveEnabled ? _saveOrder : null,
          child: const Text('Lưu Đơn'),
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
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
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
              child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _CustomerSearchField extends StatefulWidget {
  const _CustomerSearchField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.onSelected,
    required this.customersDs,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(CustomerModel) onSelected;
  final CustomersRemoteDataSource customersDs;

  @override
  State<_CustomerSearchField> createState() => _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends State<_CustomerSearchField> {
  List<CustomerModel> _suggestions = [];
  bool _loading = false;
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onQueryChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = widget.controller.text.trim();
    if (q.isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }
    _debounceSearch(q);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _debounceSearch(String q) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || q != widget.controller.text.trim()) return;
    setState(() => _loading = true);
    try {
      final list = await widget.customersDs.suggestCustomers(q);
      if (!mounted) return;
      setState(() {
        _suggestions = list;
        _loading = false;
      });
      _showOverlay();
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    }
    if (mounted) setState(() => _loading = false);
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
          offset: const Offset(0, 48),
          child: Material(
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_suggestions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Không tìm thấy khách hàng phù hợp'),
                    )
                  else
                    ..._suggestions.map((c) => ListTile(
                          title: Text('${c.code} - ${c.name} - ${c.phone} - ${c.address}'),
                          onTap: () {
                            widget.controller.text = '${c.code} - ${c.name}';
                            widget.onSelected(c);
                            _removeOverlay();
                            setState(() => _suggestions = []);
                          },
                        )),
                ],
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
        focusNode: widget.focusNode,
        controller: widget.controller,
        decoration: const InputDecoration(
          labelText: 'Tìm Mã / Tên / SĐT khách hàng',
          border: OutlineInputBorder(),
          hintText: 'Nhập mã, tên hoặc SĐT...',
        ),
        onTap: () {
          if (widget.controller.text.trim().isNotEmpty && _suggestions.isNotEmpty) {
            _showOverlay();
          }
        },
      ),
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
                    ? [const ListTile(title: Text('Không tìm thấy sản phẩm phù hợp'))]
                    : _suggestions
                        .map((p) => ListTile(
                              title: Text(
                                  '${p.code} - ${p.name} - ${p.specification} - ${p.productType} - ${p.packagingType}'),
                              onTap: () {
                                widget.onProductSelected(p);
                                _controller.text = p.code;
                                _removeOverlay();
                                setState(() => _suggestions = []);
                              },
                            ))
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

class _ConfirmOrderDialog extends StatelessWidget {
  const _ConfirmOrderDialog({
    required this.customerName,
    required this.customerCode,
    required this.items,
  });

  final String customerName;
  final String customerCode;
  final List<MapEntry<ProductSuggestModel, int>> items;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận đơn hàng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: $customerCode - $customerName'),
            const SizedBox(height: 12),
            const Text('Danh sách sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${e.key.code} ${e.key.name} x ${e.value}'),
                )),
            const SizedBox(height: 16),
            const Text('Vui lòng nhập mã PIN để ký số xác nhận.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

class _PinDialog extends StatefulWidget {
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập mã PIN'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Mã PIN',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Ký số'),
        ),
      ],
    );
  }
}
