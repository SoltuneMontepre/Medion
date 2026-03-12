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
        pageBuilder: (_, state) => NoTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', redirect: (_, __) => '/inventory'),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CustomersPage(),
            ),
          ),
          GoRoute(
            path: '/customers/create',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CreateCustomerPage(),
            ),
          ),
          GoRoute(
            path: '/customers/orders',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SalesPage(),
            ),
          ),
          GoRoute(
            path: '/customers/new-order',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const NewOrderPage(),
            ),
          ),
          GoRoute(
            path: '/customers/orders/:id',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: OrderDetailPage(
                orderId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/customers/order-summary',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OrderSummaryPage(),
            ),
          ),
          GoRoute(
            path: '/customers/order-tracking',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Theo dõi đơn hàng'),
            ),
          ),
          GoRoute(
            path: '/customers/order-return',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Hoàn đơn'),
            ),
          ),
          GoRoute(
            path: '/inventory',
            redirect: (_, __) => '/inventory/list',
          ),
          GoRoute(
            path: '/inventory/list',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InventoryPage(),
            ),
          ),
          GoRoute(
            path: '/inventory/balance',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InventoryBalancePage(section: 'raw'),
            ),
          ),
          GoRoute(
            path: '/inventory/semi',
            redirect: (_, __) => '/inventory/semi/balance',
          ),
          GoRoute(
            path: '/inventory/semi/balance',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InventoryBalancePage(section: 'semi'),
            ),
          ),
          GoRoute(
            path: '/inventory/finished',
            redirect: (_, __) => '/inventory/finished/balance',
          ),
          GoRoute(
            path: '/inventory/finished/balance',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InventoryBalancePage(section: 'finished'),
            ),
          ),
          GoRoute(
            path: '/inventory/finished-release',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FinishedProductReleasePage(),
            ),
          ),
          GoRoute(
            path: '/inventory/finished-release/create',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FinishedProductReleaseCreatePage(),
            ),
          ),
          GoRoute(
            path: '/inventory/finished-release/:id/edit',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: FinishedProductReleaseEditPage(
                id: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/production',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProductionPage(),
            ),
          ),
          GoRoute(
            path: '/production/plan',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProductionPlanPage(),
            ),
          ),
          GoRoute(
            path: '/production/plan/create',
            pageBuilder: (_, state) {
              final date = state.uri.queryParameters['date'];
              return NoTransitionPage(
                key: state.pageKey,
                child: ProductionPlanEditPage(initialDateYyyyMmDd: date),
              );
            },
          ),
          GoRoute(
            path: '/production/plan/:id/edit',
            pageBuilder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                key: state.pageKey,
                child: ProductionPlanEditPage(planId: id),
              );
            },
          ),
          GoRoute(
            path: '/production/orders',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProductionPage(),
            ),
          ),
          GoRoute(
            path: '/production/orders/create',
            pageBuilder: (_, state) {
              final productId = state.uri.queryParameters['productId'];
              final productDisplay =
                  state.uri.queryParameters['productDisplay'];
              final plannedQty =
                  int.tryParse(state.uri.queryParameters['plannedQuantity'] ?? '');
              final planItemId = state.uri.queryParameters['planItemId'];
              return NoTransitionPage(
                key: state.pageKey,
                child: ProductionOrderCreatePage(
                  productId: productId,
                  productDisplay: productDisplay,
                  plannedQuantity: plannedQty,
                  planItemId: planItemId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProductsPage(),
            ),
          ),
          GoRoute(
            path: '/ingredients',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IngredientsPage(),
            ),
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SalesPage(),
            ),
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
          GoRoute(
            path: '/qc',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const QcPage(),
            ),
          ),
          GoRoute(
            path: '/audit',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AuditPage(),
            ),
          ),
          GoRoute(
            path: '/payroll',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PayrollPage(),
            ),
          ),
          GoRoute(
            path: '/approval',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ApprovalPage(),
            ),
          ),
          GoRoute(
            path: '/roles',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const RolesPage(),
            ),
          ),
          GoRoute(
            path: '/roles/assign',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AssignRoleToUserPage(),
            ),
          ),
          GoRoute(
            path: '/roles/assign-supervisor',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AssignSupervisorPage(),
            ),
          ),
          GoRoute(
            path: '/security',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SecurityPage(),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReportsPage(),
            ),
          ),
          // Placeholder routes for nav items not yet implemented
          GoRoute(
            path: '/requests/personal',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Yêu cầu từ Cá nhân'),
            ),
          ),
          GoRoute(
            path: '/requests/department',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Yêu cầu từ Phòng ban'),
            ),
          ),
          GoRoute(
            path: '/requests/purchase',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Yêu cầu mua hàng'),
            ),
          ),
          GoRoute(
            path: '/work/mine',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Công việc của tôi'),
            ),
          ),
          GoRoute(
            path: '/work/plan',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Kế hoạch'),
            ),
          ),
          GoRoute(
            path: '/work/calendar',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Lịch'),
            ),
          ),
          GoRoute(
            path: '/documents/sop',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Tài liệu SOP'),
            ),
          ),
          GoRoute(
            path: '/workshop',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Xưởng'),
            ),
          ),
          GoRoute(
            path: '/products/recall',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Thu hồi sản phẩm'),
            ),
          ),
          GoRoute(
            path: '/departments',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Phòng ban'),
            ),
          ),
          GoRoute(
            path: '/partners',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Đối tác'),
            ),
          ),
          GoRoute(
            path: '/risk',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlaceholderPage(title: 'Rủi ro'),
            ),
          ),
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
