import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories_impl/user_roles_repository_impl.dart';
import '../providers/roles_provider.dart';

const int _pageSize = 20;

/// Gán vai trò cho user — list users, select user, check roles, save.
class AssignRoleToUserPage extends ConsumerStatefulWidget {
  const AssignRoleToUserPage({super.key});

  @override
  ConsumerState<AssignRoleToUserPage> createState() =>
      _AssignRoleToUserPageState();
}

class _AssignRoleToUserPageState extends ConsumerState<AssignRoleToUserPage> {
  int _page = 1;
  User? _selectedUser;
  Set<String> _selectedRoleIds = {};
  bool _saving = false;

  Future<void> _saveRoles() async {
    if (_selectedUser == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(userRolesRepositoryProvider);
      await repo.setUserRoles(
          _selectedUser!.id, _selectedRoleIds.toList()..sort());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật vai trò.')),
        );
        ref.invalidate(userRolesProvider(_selectedUser!.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider(_page));
    final allRolesAsync = ref.watch(allRolesProvider);
    final userRolesAsync = _selectedUser != null
        ? ref.watch(userRolesProvider(_selectedUser!.id))
        : null;

    final total = usersAsync.valueOrNull?.total ?? 0;
    final totalPages =
        ((total + _pageSize - 1) / _pageSize).ceil().clamp(1, 0x7fffffff);
    final allRoles = allRolesAsync.valueOrNull ?? [];

    return AppScaffold(
      title: 'Gán vai trò cho user',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: usersAsync.when(
              data: (result) {
                final rows = result.items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        'Chọn user',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 320,
                        columns: const [
                          DataColumn2(label: Text('Username'), size: ColumnSize.S),
                          DataColumn2(label: Text('Email'), size: ColumnSize.L),
                        ],
                        rows: rows.map((u) {
                          final selected = _selectedUser?.id == u.id;
                          return DataRow2(
                            selected: selected,
                            onSelectChanged: (_) {
                              setState(() {
                                _selectedUser = selected ? null : u;
                                _selectedRoleIds = {};
                              });
                              if (_selectedUser != null) {
                                ref.read(userRolesProvider(_selectedUser!.id));
                              }
                            },
                            cells: [
                              DataCell(Text(u.username)),
                              DataCell(Text(u.email)),
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
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
            ),
          ),
          Container(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            flex: 1,
            child: _selectedUser == null
                ? const Center(
                    child: Text(
                      'Chọn một user bên trái để gán vai trò.',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                : _RolePanel(
                    user: _selectedUser!,
                    allRoles: allRoles,
                    userRolesAsync: userRolesAsync,
                    selectedRoleIds: _selectedRoleIds,
                    onSelectionChanged: (ids) =>
                        setState(() => _selectedRoleIds = ids),
                    onSave: _saveRoles,
                    saving: _saving,
                  ),
          ),
        ],
      ),
    );
  }
}

class _RolePanel extends StatefulWidget {
  const _RolePanel({
    required this.user,
    required this.allRoles,
    required this.userRolesAsync,
    required this.selectedRoleIds,
    required this.onSelectionChanged,
    required this.onSave,
    required this.saving,
  });

  final User user;
  final List<Role> allRoles;
  final AsyncValue<List<Role>>? userRolesAsync;
  final Set<String> selectedRoleIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final VoidCallback onSave;
  final bool saving;

  @override
  State<_RolePanel> createState() => _RolePanelState();
}

class _RolePanelState extends State<_RolePanel> {
  @override
  Widget build(BuildContext context) {
    if (widget.userRolesAsync == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.userRolesAsync!.when(
      data: (currentRoles) {
        final currentIds = currentRoles.map((r) => r.id).toSet();
        final selected = widget.selectedRoleIds.isNotEmpty
            ? widget.selectedRoleIds
            : currentIds;
        if (widget.selectedRoleIds.isEmpty && currentIds.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSelectionChanged(currentIds);
          });
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vai trò: ${widget.user.username}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...widget.allRoles.map((role) {
                final isChecked = selected.contains(role.id);
                return CheckboxListTile(
                  title: Text(role.name),
                  subtitle: Text(role.code),
                  value: isChecked,
                  onChanged: (value) {
                    final next = Set<String>.from(selected);
                    if (value == true) {
                      next.add(role.id);
                    } else {
                      next.remove(role.id);
                    }
                    widget.onSelectionChanged(next);
                  },
                );
              }),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: widget.saving ? null : widget.onSave,
                child: widget.saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu vai trò'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi: $err')),
    );
  }
}
