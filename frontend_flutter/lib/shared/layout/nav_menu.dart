/// One item in the app nav: either a leaf (path) or a group with [children].
class NavItem {
  const NavItem({
    required this.label,
    this.path,
    this.children = const [],
  }); // Either path or children must be set; prefer path for leaf, children for group

  final String label;
  final String? path;
  final List<NavItem> children;

  bool get hasChildren => children.isNotEmpty;
}

/// Full nav bar content: top-level items with nested sub-items (indentation = child).
/// Matches the hierarchy: Yêu cầu, Công việc, Tài liệu, Kho, Xưởng, Sản xuất, Sản phẩm, Tài chính, Nhân sự, Khách hàng, Đối tác, Rủi ro.
class NavMenu {
  NavMenu._();

  static final List<NavItem> items = [
    NavItem(
      label: 'Yêu cầu',
      children: [
        NavItem(label: 'từ Cá nhân', path: '/requests/personal'),
        NavItem(label: 'từ Phòng ban', path: '/requests/department'),
        NavItem(label: 'yêu cầu mua hàng', path: '/requests/purchase'),
      ],
    ),
    NavItem(
      label: 'Công việc',
      children: [
        NavItem(label: 'của tôi', path: '/work/mine'),
        NavItem(label: 'kế hoạch', path: '/work/plan'),
        NavItem(label: 'lịch', path: '/work/calendar'),
      ],
    ),
    NavItem(
      label: 'Tài liệu',
      children: [
        NavItem(label: 'SOP', path: '/documents/sop'),
      ],
    ),
    NavItem(
      label: 'Kho',
      children: [
        NavItem(label: 'kho NVP', path: '/inventory'),
        NavItem(label: 'kho BTP', path: '/inventory/semi'),
        NavItem(label: 'kho TP', path: '/inventory/finished'),
        NavItem(label: 'Phiếu xuất kho TP', path: '/inventory/finished-release'),
      ],
    ),
    NavItem(label: 'Xưởng', path: '/workshop'),
    NavItem(
      label: 'Sản xuất',
      children: [
        NavItem(label: 'Tổng quan', path: '/production'),
        NavItem(label: 'Kế hoạch sản xuất', path: '/production/plan'),
        NavItem(label: 'Lệnh sản xuất', path: '/production/orders'),
      ],
    ),
    NavItem(
      label: 'Sản phẩm',
      children: [
        NavItem(label: 'Danh sách sản phẩm', path: '/products'),
        NavItem(label: 'Nguyên liệu', path: '/ingredients'),
        NavItem(label: 'Thu hồi sản phẩm', path: '/products/recall'),
      ],
    ),
    NavItem(label: 'Tài chính', path: '/sales'),
    NavItem(
      label: 'Nhân sự',
      children: [
        NavItem(label: 'Vai trò & phân cấp', path: '/roles'),
        NavItem(label: 'Gán vai trò user', path: '/roles/assign'),
        NavItem(label: 'Gán cấp trên', path: '/roles/assign-supervisor'),
        NavItem(label: 'Phòng ban', path: '/departments'),
      ],
    ),
    NavItem(
      label: 'Khách hàng',
      children: [
        NavItem(label: 'Khách hàng', path: '/customers'),
        NavItem(label: 'Đơn hàng', path: '/customers/orders'),
        NavItem(label: 'Tổng hợp đơn hàng', path: '/customers/order-summary'),
        NavItem(label: 'Theo dõi đơn hàng', path: '/customers/order-tracking'),
        NavItem(label: 'Hoàn đơn', path: '/customers/order-return'),
      ],
    ),
    NavItem(label: 'Đối tác', path: '/partners'),
    NavItem(label: 'Rủi ro', path: '/risk'),
  ];

  /// First path to navigate when user taps a parent that has children (e.g. Kho -> first child path).
  static String? firstPathOf(NavItem item) {
    if (item.path != null && item.path!.isNotEmpty) return item.path;
    if (item.hasChildren) return firstPathOf(item.children.first);
    return null;
  }

  /// Whether [path] is under this item (exact or prefix).
  static bool itemMatchesPath(NavItem item, String path) {
    final p = item.path;
    if (p != null && p.isNotEmpty) {
      return path == p || (path.startsWith(p) && (path.length == p.length || path[p.length] == '/'));
    }
    return item.children.any((c) => itemMatchesPath(c, path));
  }
}
