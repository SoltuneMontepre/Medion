import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../modules/approval/presentation/pages/approval_page.dart';
import '../../modules/audit/presentation/pages/audit_page.dart';
import '../../modules/customers/presentation/pages/create_customer_page.dart';
import '../../modules/customers/presentation/pages/customers_page.dart';
import '../../modules/inventory/presentation/pages/finished_product_release_page.dart';
import '../../modules/inventory/presentation/pages/inventory_page.dart';
import '../../modules/payroll/presentation/pages/payroll_page.dart';
import '../../modules/production/presentation/pages/production_page.dart';
import '../../modules/production/presentation/pages/production_plan_page.dart';
import '../../modules/qc/presentation/pages/qc_page.dart';
import '../../modules/reports/presentation/pages/reports_page.dart';
import '../../modules/sales/presentation/pages/order_summary_page.dart';
import '../../modules/sales/presentation/pages/sales_page.dart';
import '../../modules/security/presentation/pages/security_page.dart';
import '../../shared/layout/app_shell.dart';
import 'home_page.dart';

/// Central routing via go_router. No module imports another module.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const DashboardPage()),
          GoRoute(path: '/customers', builder: (_, _) => const CustomersPage()),
          GoRoute(
            path: '/customers/create',
            builder: (_, _) => const CreateCustomerPage(),
          ),
          GoRoute(path: '/inventory', builder: (_, _) => const InventoryPage()),
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
            path: '/sales/order-summary',
            builder: (_, _) => const OrderSummaryPage(),
          ),
          GoRoute(path: '/qc', builder: (_, _) => const QcPage()),
          GoRoute(path: '/audit', builder: (_, _) => const AuditPage()),
          GoRoute(path: '/payroll', builder: (_, _) => const PayrollPage()),
          GoRoute(path: '/approval', builder: (_, _) => const ApprovalPage()),
          GoRoute(path: '/security', builder: (_, _) => const SecurityPage()),
          GoRoute(path: '/reports', builder: (_, _) => const ReportsPage()),
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
