import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/layout/app_scaffold.dart';
import '../../../../shared/widgets/toolbar.dart';
import '../../data/repositories_impl/roles_repository_impl.dart';
import '../../domain/entities/role.dart';
import '../providers/roles_provider.dart';
import '../widgets/role_form_dialog.dart';

const int _pageSize = 20;

/// Vai trò & phân cấp vai trò — CRUD and hierarchy (parent role).
class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key});

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  int _page = 1;
  Role? _selectedRole;

  void _clearSelection() {
    if (_selectedRole != null) setState(() => _selectedRole = null);
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(rolesProvider(_page));
    final allRolesAsync = ref.watch(allRolesProvider);
    final total = resultAsync.valueOrNull?.total ?? 0;
    final totalPages = ((total + _pageSize - 1) / _pageSize).ceil().clamp(1, 0x7fffffff);
    final repo = ref.read(rolesRepositoryProvider);
    final allRoles = allRolesAsync.valueOrNull ?? [];

    return AppScaffold(
      title: 'Vai trò & phân cấp',
      toolbarActions: [
        ToolbarButton(
          label: 'Tạo mới',
          icon: Icons.add,
          onPressed: () async {
            final created = await showRoleFormDialog(
              context,
              repository: repo,
              allRoles: allRoles,
            );
            if (created != null && mounted) {
              ref.invalidate(rolesProvider(_page));
              ref.invalidate(allRolesProvider);
              _clearSelection();
            }
          },
        ),
        ToolbarButton(
          label: 'Sửa',
          icon: Icons.edit,
          onPressed: _selectedRole == null
              ? null
              : () async {
                  final updated = await showRoleFormDialog(
                    context,
                    role: _selectedRole,
                    repository: repo,
                    allRoles: allRoles,
                  );
                  if (updated != null && mounted) {
                    ref.invalidate(rolesProvider(_page));
                    ref.invalidate(allRolesProvider);
                    setState(() => _selectedRole = updated);
                  }
                },
        ),
        ToolbarButton(
          label: 'Xóa',
          icon: Icons.delete,
          onPressed: _selectedRole == null
              ? null
              : () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Xóa vai trò',
                    message:
                        'Bạn có chắc muốn xóa "${_selectedRole!.name}" (${_selectedRole!.code})? Vai trò không được gán cho user và không có vai trò con.',
                    isDestructive: true,
                  );
                  if (!ok || !mounted) return;
                  try {
                    await repo.deleteRole(_selectedRole!.id);
                    if (mounted) {
                      ref.invalidate(rolesProvider(_page));
                      ref.invalidate(allRolesProvider);
                      _clearSelection();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
        ),
      ],
      child: resultAsync.when(
        data: (result) {
          final rows = result.items;
          return Column(
            children: [
              Expanded(
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  sortColumnIndex: 0,
                  sortAscending: true,
                  columns: const [
                    DataColumn2(label: Text('Mã'), size: ColumnSize.S),
                    DataColumn2(label: Text('Tên'), size: ColumnSize.L),
                    DataColumn2(label: Text('Mô tả'), size: ColumnSize.L),
                    DataColumn2(label: Text('Vai trò cha'), size: ColumnSize.S),
                  ],
                  rows: rows.map((r) {
                    final selected = _selectedRole?.id == r.id;
                    return DataRow2(
                      selected: selected,
                      onSelectChanged: (_) => setState(() {
                        _selectedRole = selected ? null : r;
                      }),
                      cells: [
                        DataCell(Text(r.code)),
                        DataCell(Text(r.name)),
                        DataCell(Text(r.description)),
                        DataCell(Text(r.parentCode ?? '—')),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _page <= 1
                            ? null
                            : () => setState(() => _page--),
                      ),
                      Text('Trang $_page / $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _page >= totalPages
                            ? null
                            : () => setState(() => _page++),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Phân cấp: vai trò cha → con (dùng cho kế thừa quyền).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
