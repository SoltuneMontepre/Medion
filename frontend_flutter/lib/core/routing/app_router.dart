import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../auth/presentation/login_page.dart';
import '../../modules/approval/presentation/pages/approval_page.dart';
import '../../modules/audit/presentation/pages/audit_page.dart';
import '../../modules/customers/presentation/pages/create_customer_page.dart';
import '../../modules/customers/presentation/pages/customers_page.dart';
import '../../modules/inventory/presentation/pages/finished_product_release_page.dart';
import '../../modules/inventory/presentation/pages/inventory_page.dart';
import '../../modules/inventory/presentation/pages/inventory_section_page.dart';
import '../../modules/payroll/presentation/pages/payroll_page.dart';
import '../../modules/production/presentation/pages/production_page.dart';
import '../../modules/production/presentation/pages/production_plan_page.dart';
import '../../modules/qc/presentation/pages/qc_page.dart';
import '../../modules/reports/presentation/pages/reports_page.dart';
import '../../modules/sales/presentation/pages/new_order_page.dart';
import '../../modules/sales/presentation/pages/order_detail_page.dart';
import '../../modules/sales/presentation/pages/order_summary_page.dart';
import '../../modules/sales/presentation/pages/sales_page.dart';
import '../../modules/security/presentation/pages/security_page.dart';
import '../../shared/layout/app_shell.dart';
import 'home_page.dart';
import 'placeholder_page.dart';

/// Central routing via go_router. No module imports another module.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/inventory',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final path = state.uri.path;
      if (!auth.isAuthenticated && path != '/login') return '/login';
      if (auth.isAuthenticated && path == '/login') return '/inventory';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', redirect: (_, __) => '/inventory'),
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
          GoRoute(path: '/customers', builder: (_, _) => const CustomersPage()),
          GoRoute(
            path: '/customers/create',
            builder: (_, _) => const CreateCustomerPage(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (_, _) => const InventorySectionPage(sub: 'raw'),
          ),
          GoRoute(
            path: '/inventory/list',
            builder: (_, _) => const InventoryPage(),
          ),
          GoRoute(
            path: '/inventory/semi',
            builder: (_, _) => const InventorySectionPage(sub: 'semi'),
          ),
          GoRoute(
            path: '/inventory/finished',
            builder: (_, _) => const InventorySectionPage(sub: 'finished'),
          ),
          GoRoute(
            path: '/inventory/finished-release',
            builder: (_, _) => const FinishedProductReleasePage(),
          ),
          GoRoute(
            path: '/production',
            builder: (_, _) => const ProductionPage(),
          ),
          GoRoute(
            path: '/production/plan',
            builder: (_, _) => const ProductionPlanPage(),
          ),
          GoRoute(path: '/sales', builder: (_, _) => const SalesPage()),
          GoRoute(
            path: '/sales/new-order',
            builder: (_, _) => const NewOrderPage(),
          ),
          GoRoute(
            path: '/sales/orders/:id',
            builder: (_, state) => OrderDetailPage(
              orderId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/sales/order-summary',
            builder: (_, _) => const OrderSummaryPage(),
          ),
          GoRoute(path: '/qc', builder: (_, _) => const QcPage()),
          GoRoute(path: '/audit', builder: (_, _) => const AuditPage()),
          GoRoute(path: '/payroll', builder: (_, _) => const PayrollPage()),
          GoRoute(path: '/approval', builder: (_, _) => const ApprovalPage()),
          GoRoute(path: '/security', builder: (_, _) => const SecurityPage()),
          GoRoute(path: '/reports', builder: (_, _) => const ReportsPage()),
          // Placeholder routes for nav items not yet implemented
          GoRoute(path: '/requests/personal', builder: (_, _) => const PlaceholderPage(title: 'Yêu cầu từ Cá nhân')),
          GoRoute(path: '/requests/department', builder: (_, _) => const PlaceholderPage(title: 'Yêu cầu từ Phòng ban')),
          GoRoute(path: '/requests/purchase', builder: (_, _) => const PlaceholderPage(title: 'Yêu cầu mua hàng')),
          GoRoute(path: '/work/mine', builder: (_, _) => const PlaceholderPage(title: 'Công việc của tôi')),
          GoRoute(path: '/work/plan', builder: (_, _) => const PlaceholderPage(title: 'Kế hoạch')),
          GoRoute(path: '/work/calendar', builder: (_, _) => const PlaceholderPage(title: 'Lịch')),
          GoRoute(path: '/documents/sop', builder: (_, _) => const PlaceholderPage(title: 'Tài liệu SOP')),
          GoRoute(path: '/workshop', builder: (_, _) => const PlaceholderPage(title: 'Xưởng')),
          GoRoute(path: '/products/recall', builder: (_, _) => const PlaceholderPage(title: 'Thu hồi sản phẩm')),
          GoRoute(path: '/departments', builder: (_, _) => const PlaceholderPage(title: 'Phòng ban')),
          GoRoute(path: '/partners', builder: (_, _) => const PlaceholderPage(title: 'Đối tác')),
          GoRoute(path: '/risk', builder: (_, _) => const PlaceholderPage(title: 'Rủi ro')),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.uri}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
});
