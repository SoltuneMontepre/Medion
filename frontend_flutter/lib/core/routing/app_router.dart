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
import '../../modules/inventory/presentation/pages/finished_product_release_create_page.dart';
import '../../modules/inventory/presentation/pages/finished_product_release_edit_page.dart';
import '../../modules/inventory/presentation/pages/inventory_balance_page.dart';
import '../../modules/inventory/presentation/pages/inventory_page.dart';
import '../../modules/payroll/presentation/pages/payroll_page.dart';
import '../../modules/production/presentation/pages/production_page.dart';
import '../../modules/production/presentation/pages/production_plan_page.dart';
import '../../modules/production/presentation/pages/production_plan_edit_page.dart';
import '../../modules/production/presentation/pages/production_order_create_page.dart';
import '../../modules/qc/presentation/pages/qc_page.dart';
import '../../modules/reports/presentation/pages/reports_page.dart';
import '../../modules/sales/presentation/pages/new_order_page.dart';
import '../../modules/sales/presentation/pages/order_detail_page.dart';
import '../../modules/sales/presentation/pages/order_summary_page.dart';
import '../../modules/sales/presentation/pages/sales_page.dart';
import '../../modules/ingredients/presentation/pages/ingredients_page.dart';
import '../../modules/products/presentation/pages/products_page.dart';
import '../../modules/roles/presentation/pages/assign_role_to_user_page.dart';
import '../../modules/roles/presentation/pages/assign_supervisor_page.dart';
import '../../modules/roles/presentation/pages/roles_page.dart';
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
            path: '/customers/orders',
            builder: (_, _) => const SalesPage(),
          ),
          GoRoute(
            path: '/customers/new-order',
            builder: (_, _) => const NewOrderPage(),
          ),
          GoRoute(
            path: '/customers/orders/:id',
            builder: (_, state) => OrderDetailPage(
              orderId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/customers/order-summary',
            builder: (_, _) => const OrderSummaryPage(),
          ),
          GoRoute(
            path: '/customers/order-tracking',
            builder: (_, _) =>
                const PlaceholderPage(title: 'Theo dõi đơn hàng'),
          ),
          GoRoute(
            path: '/customers/order-return',
            builder: (_, _) => const PlaceholderPage(title: 'Hoàn đơn'),
          ),
          GoRoute(
            path: '/inventory',
            redirect: (_, __) => '/inventory/list',
          ),
          GoRoute(
            path: '/inventory/list',
            builder: (_, _) => const InventoryPage(),
          ),
          GoRoute(
            path: '/inventory/balance',
            builder: (_, _) => const InventoryBalancePage(section: 'raw'),
          ),
          GoRoute(
            path: '/inventory/semi',
            redirect: (_, __) => '/inventory/semi/balance',
          ),
          GoRoute(
            path: '/inventory/semi/balance',
            builder: (_, _) => const InventoryBalancePage(section: 'semi'),
          ),
          GoRoute(
            path: '/inventory/finished',
            redirect: (_, __) => '/inventory/finished/balance',
          ),
          GoRoute(
            path: '/inventory/finished/balance',
            builder: (_, _) => const InventoryBalancePage(section: 'finished'),
          ),
          GoRoute(
            path: '/inventory/finished-release',
            builder: (_, _) => const FinishedProductReleasePage(),
          ),
          GoRoute(
            path: '/inventory/finished-release/create',
            builder: (_, _) => const FinishedProductReleaseCreatePage(),
          ),
          GoRoute(
            path: '/inventory/finished-release/:id/edit',
            builder: (_, state) => FinishedProductReleaseEditPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/production',
            builder: (_, _) => const ProductionPage(),
          ),
          GoRoute(
            path: '/production/plan',
            builder: (_, _) => const ProductionPlanPage(),
          ),
          GoRoute(
            path: '/production/plan/create',
            builder: (_, state) {
              final date = state.uri.queryParameters['date'];
              return ProductionPlanEditPage(initialDateYyyyMmDd: date);
            },
          ),
          GoRoute(
            path: '/production/plan/:id/edit',
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return ProductionPlanEditPage(planId: id);
            },
          ),
          GoRoute(
            path: '/production/orders',
            builder: (_, _) => const ProductionPage(),
          ),
          GoRoute(
            path: '/production/orders/create',
            builder: (_, state) {
              final productId = state.uri.queryParameters['productId'];
              final productDisplay =
                  state.uri.queryParameters['productDisplay'];
              final plannedQty =
                  int.tryParse(state.uri.queryParameters['plannedQuantity'] ?? '');
              final planItemId = state.uri.queryParameters['planItemId'];
              return ProductionOrderCreatePage(
                productId: productId,
                productDisplay: productDisplay,
                plannedQuantity: plannedQty,
                planItemId: planItemId,
              );
            },
          ),
          GoRoute(path: '/products', builder: (_, _) => const ProductsPage()),
          GoRoute(path: '/ingredients', builder: (_, _) => const IngredientsPage()),
          GoRoute(
            path: '/sales',
            builder: (_, __) => const SalesPage(),
          ),
          GoRoute(
            path: '/sales/new-order',
            redirect: (_, __) => '/customers/new-order',
          ),
          GoRoute(
            path: '/sales/orders/:id',
            redirect: (_, state) =>
                '/customers/orders/${state.pathParameters['id'] ?? ''}',
          ),
          GoRoute(
            path: '/sales/order-summary',
            redirect: (_, __) => '/customers/order-summary',
          ),
          GoRoute(path: '/qc', builder: (_, _) => const QcPage()),
          GoRoute(path: '/audit', builder: (_, _) => const AuditPage()),
          GoRoute(path: '/payroll', builder: (_, _) => const PayrollPage()),
          GoRoute(path: '/approval', builder: (_, _) => const ApprovalPage()),
          GoRoute(path: '/roles', builder: (_, _) => const RolesPage()),
          GoRoute(
            path: '/roles/assign',
            builder: (_, _) => const AssignRoleToUserPage(),
          ),
          GoRoute(
            path: '/roles/assign-supervisor',
            builder: (_, _) => const AssignSupervisorPage(),
          ),
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
