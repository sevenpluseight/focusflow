import 'package:flutter/material.dart';
import 'package:focusflow/providers/admin_users_provider.dart'; // Changed import
import 'package:focusflow/theme/app_theme.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/models/models.dart';
import 'package:provider/provider.dart'; // Import Provider

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(String role, bool isDark) {
    switch (role) {
      case 'admin':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'coach':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'user':
      default:
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Pixel.lock;
      case 'coach':
        return Pixel.bullseye;
      case 'user':
      default:
        return Pixel.user;
    }
  }

  Future<String?> _showAdminActionDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> actions,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 50.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,

          title: null,

          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(children: actions),
                  ],
                ),
              ),
              Positioned(
                top: 12.0,
                right: 12.0,
                child: IconButton(
                  icon: Icon(
                    Pixel.close,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final theme = Theme.of(context);
    final bg =
        backgroundColor ??
        theme.elevatedButtonTheme.style?.backgroundColor?.resolve({});
    final fg =
        foregroundColor ??
        theme.elevatedButtonTheme.style?.foregroundColor?.resolve({});

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
      child: Text(text),
    );
  }

  Future<void> _showRoleChangeDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final theme = Theme.of(context);
    final provider = context.read<AdminUsersProvider>();

    final isUser = user.role == 'user';
    final isCoach = user.role == 'coach';

    final String? selectedRole = await _showAdminActionDialog(
      context,
      title: 'Change User Role',
      subtitle: 'Promote or Demote ${user.username}',
      actions: [
        // Promote Button
        _buildDialogButton(
          context,
          text: 'Promote',
          onPressed: isUser ? () => Navigator.pop(context, 'coach') : null,
        ),
        const SizedBox(height: 12),
        // Demote Button
        _buildDialogButton(
          context,
          text: 'Demote',
          onPressed: isCoach ? () => Navigator.pop(context, 'user') : null,
        ),
      ],
    );

    // This logic stays the same and works perfectly!
    if (selectedRole != null) {
      if (!mounted) return;
      final success = await provider.changeUserRole(user.uid, selectedRole);
      if (mounted) {
        if (success) {
          CustomSnackBar.show(
            context,
            message: 'Role updated to $selectedRole',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
        } else {
          CustomSnackBar.show(
            context,
            message: 'Failed to update role: ${provider.errorMessage}',
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    UserModel user,
  ) async {
    final theme = Theme.of(context);
    final provider = context.read<AdminUsersProvider>();

    final String? action = await _showAdminActionDialog(
      context,
      title: 'Account Status',
      subtitle: 'Deactivate or Ban ${user.username}?',
      actions: [
        // Deactivate Button
        _buildDialogButton(
          context,
          text: 'Deactivate',
          backgroundColor: theme.colorScheme.error, // Red color
          foregroundColor: theme.colorScheme.onError, // White text
          onPressed: () => Navigator.pop(context, 'deactivate'),
        ),
        const SizedBox(height: 12),
        // Ban Button
        _buildDialogButton(
          context,
          text: 'Ban',
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onErrorContainer,
          onPressed: () => Navigator.pop(context, 'ban'),
        ),
      ],
    );

    if (action == 'deactivate') {
      if (!mounted) return;
      final success = await provider.deleteUser(user.uid);
      if (mounted) {
        if (success) {
          CustomSnackBar.show(
            context,
            message: 'User deleted successfully',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
        } else {
          CustomSnackBar.show(
            context,
            message: 'Failed to delete user: ${provider.errorMessage}',
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
        }
      }
    } else if (action == 'ban') {
      // TODO: Implement your ban logic here
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Ban logic not implemented yet.',
          type: SnackBarType.info,
          position: SnackBarPosition.top,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final provider = context.watch<AdminUsersProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF3A3D42) : Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<AdminUsersProvider>().updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search by name or email...',
                    prefixIcon: Icon(Pixel.search),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Pixel.close),
                            onPressed: () {
                              _searchController.clear();
                              context.read<AdminUsersProvider>().clearSearch();
                            },
                          )
                        : null,
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Filter:',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'All', isDark, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip('user', 'Users', isDark, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'coach',
                              'Coaches',
                              isDark,
                              provider,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'admin',
                              'Admins',
                              isDark,
                              provider,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.allUsers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Pixel.close, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading users',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final filteredUsers = provider.filteredUsers;

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Pixel.users,
                          size: 48,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, theme, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    bool isDark,
    AdminUsersProvider provider,
  ) {
    final theme = Theme.of(context);

    final isSelected = provider.selectedRoleFilter == value;

    return SafeArea(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          context.read<AdminUsersProvider>().updateRoleFilter(value);
        },
        backgroundColor: isDark
            ? theme.colorScheme.surface
            : AppTheme.lightBackground,
        selectedColor: isDark
            ? theme.colorScheme.primary
            : Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected
              ? (isDark ? Colors.black : Colors.blue.shade900)
              : (isDark ? Colors.white70 : Colors.black54),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: isDark ? Colors.black : Colors.blue.shade900,
      ),
    );
  }

  Widget _buildUserCard(UserModel user, ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final joinDate = dateFormat.format(user.createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StyledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRoleColor(
                    user.role,
                    isDark,
                  ).withOpacity(0.2),
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role, isDark),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(
                      user.role,
                      isDark,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getRoleColor(user.role, isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white24 : Colors.black12, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Pixel.calendar,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  'Joined: $joinDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Pixel.login,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  user.signInMethod,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (user.role != 'admin')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showRoleChangeDialog(context, user),
                    icon: const Icon(Pixel.edit, size: 16),
                    label: const Text('Manage Role'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, user),
                    icon: const Icon(Pixel.save, size: 16),
                    label: const Text('Account Status'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
