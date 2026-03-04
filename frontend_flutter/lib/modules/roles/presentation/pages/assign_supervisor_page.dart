import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/layout/app_scaffold.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories_impl/user_roles_repository_impl.dart';
import '../providers/roles_provider.dart';

const int _pageSize = 20;

/// Gán cấp trên (supervisor) cho user — list users, select user, choose supervisor, save.
class AssignSupervisorPage extends ConsumerStatefulWidget {
  const AssignSupervisorPage({super.key});

  @override
  ConsumerState<AssignSupervisorPage> createState() =>
      _AssignSupervisorPageState();
}

class _AssignSupervisorPageState extends ConsumerState<AssignSupervisorPage> {
  int _page = 1;
  User? _selectedUser;
  String? _selectedSupervisorId; // null = no supervisor
  bool _saving = false;

  Future<void> _saveSupervisor() async {
    if (_selectedUser == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(userRolesRepositoryProvider);
      await repo.setSupervisor(_selectedUser!.id, _selectedSupervisorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật cấp trên.')),
        );
        ref.invalidate(usersProvider(_page));
        setState(() {
          _selectedUser = _selectedUser != null
              ? User(
                  id: _selectedUser!.id,
                  username: _selectedUser!.username,
                  email: _selectedUser!.email,
                  supervisorId: _selectedSupervisorId,
                  supervisorUsername: null,
                )
              : null;
        });
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
    final allUsersAsync = ref.watch(allUsersProvider);

    final total = usersAsync.valueOrNull?.total ?? 0;
    final totalPages =
        ((total + _pageSize - 1) / _pageSize).ceil().clamp(1, 0x7fffffff);
    final allUsers = allUsersAsync.valueOrNull ?? [];

    return AppScaffold(
      title: 'Gán cấp trên',
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
                        minWidth: 400,
                        columns: const [
                          DataColumn2(
                              label: Text('Username'), size: ColumnSize.S),
                          DataColumn2(
                              label: Text('Email'), size: ColumnSize.L),
                          DataColumn2(
                              label: Text('Cấp trên'), size: ColumnSize.S),
                        ],
                        rows: rows.map((u) {
                          final selected = _selectedUser?.id == u.id;
                          return DataRow2(
                            selected: selected,
                            onSelectChanged: (_) {
                              setState(() {
                                _selectedUser = selected ? null : u;
                                _selectedSupervisorId = _selectedUser?.supervisorId;
                              });
                            },
                            cells: [
                              DataCell(Text(u.username)),
                              DataCell(Text(u.email)),
                              DataCell(Text(
                                  u.supervisorUsername ?? u.supervisorId ?? '—')),
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
                      'Chọn một user bên trái để gán cấp trên.',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                : _SupervisorPanel(
                    user: _selectedUser!,
                    allUsers: allUsers,
                    selectedSupervisorId: _selectedSupervisorId,
                    onSupervisorChanged: (id) =>
                        setState(() => _selectedSupervisorId = id),
                    onSave: _saveSupervisor,
                    saving: _saving,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorPanel extends StatelessWidget {
  const _SupervisorPanel({
    required this.user,
    required this.allUsers,
    required this.selectedSupervisorId,
    required this.onSupervisorChanged,
    required this.onSave,
    required this.saving,
  });

  final User user;
  final List<User> allUsers;
  final String? selectedSupervisorId;
  final ValueChanged<String?> onSupervisorChanged;
  final VoidCallback onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    // Exclude current user from supervisor options (cannot be own supervisor)
    final supervisorOptions = allUsers.where((u) => u.id != user.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cấp trên: ${user.username}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Cấp trên hiện tại: ${user.supervisorUsername ?? user.supervisorId ?? 'Không có'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: selectedSupervisorId,
            decoration: const InputDecoration(
              labelText: 'Chọn cấp trên',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('— Không có cấp trên'),
              ),
              ...supervisorOptions.map((u) => DropdownMenuItem<String?>(
                    value: u.id,
                    child: Text('${u.username} (${u.email})'),
                  )),
            ],
            onChanged: (value) => onSupervisorChanged(value),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu cấp trên'),
          ),
        ],
      ),
    );
  }
}
