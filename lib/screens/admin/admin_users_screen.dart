import 'package:flutter/material.dart';
import 'package:focusflow/theme/app_theme.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  @override
  // release memory and listeners
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

  // set role icon
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

  // get the list of users based on search and filter
  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // filter by search string
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // filter by role
      final matchesRole =
          _selectedRoleFilter == 'all' || user.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _showRoleChangeDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String? selectedRole = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String tempRole = user.role;
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Change Role for ${user.username}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(
                      'User',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    value: 'user',
                    groupValue: tempRole,
                    onChanged: (value) {
                      setDialogState(() => tempRole = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'Coach',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    value: 'coach',
                    groupValue: tempRole,
                    onChanged: (value) {
                      setDialogState(() => tempRole = value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'Admin',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    value: 'admin',
                    groupValue: tempRole,
                    onChanged: (value) {
                      setDialogState(() => tempRole = value!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, tempRole),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (selectedRole != null && selectedRole != user.role) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final success = await _userService.updateUserRole(user.uid, selectedRole);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Role updated to $selectedRole'
                  : 'Failed to update role',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _showDeleteConfirmation(
  //   BuildContext context,
  //   UserModel user,
  // ) async {
  //   final theme = Theme.of(context);
  //   final isDark = theme.brightness == Brightness.dark;

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: theme.scaffoldBackgroundColor,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         title: Text(
  //           'Delete User',
  //           style: TextStyle(
  //             color: isDark ? Colors.white : Colors.black87,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Text(
  //           'Are you sure you want to delete ${user.username}? This action cannot be undone.',
  //           style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext, false),
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: isDark ? Colors.white70 : Colors.black54,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext, true),
  //             child: const Text(
  //               'Delete',
  //               style: TextStyle(
  //                 color: Colors.red,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmed == true) {
  //     if (!mounted) return;
  //     final messenger = ScaffoldMessenger.of(context);
  //     final success = await _userService.deleteUser(user.uid);
  //     if (mounted) {
  //       messenger.showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             success ? 'User deleted successfully' : 'Failed to delete user',
  //           ),
  //           backgroundColor: success ? Colors.green : Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // search & filter
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    prefixIcon: Icon(
                      Pixel.search,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Pixel.close,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surface
                        : AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Role Filter
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
                            _buildFilterChip('all', 'All', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('user', 'Users', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('coach', 'Coaches', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('admin', 'Admins', isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _userService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
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
                          snapshot.error.toString(),
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

                final allUsers = snapshot.data ?? [];
                final filteredUsers = _filterUsers(allUsers);

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

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final theme = Theme.of(context);
    final isSelected = _selectedRoleFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedRoleFilter = value);
      },
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : AppTheme.lightBackground,
      selectedColor: isDark ? theme.colorScheme.primary : Colors.blue.shade100,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? Colors.white : Colors.blue.shade900)
            : (isDark ? Colors.white70 : Colors.black54),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: isDark ? Colors.white : Colors.blue.shade900,
    );
  }

  Widget _buildUserCard(UserModel user, ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final joinDate = dateFormat.format(user.createdAt.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  ).withValues(alpha: 0.2),
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
                        style: theme.textTheme.bodySmall?.copyWith(
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
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white24 : Colors.black12, height: 1),
            const SizedBox(height: 12),
            // Additional Info
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
                  style: theme.textTheme.bodySmall?.copyWith(
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            if (user.role != 'admin')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showRoleChangeDialog(context, user),
                    icon: const Icon(Pixel.edit, size: 16),
                    label: const Text('Manage Role'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white54 : Colors.black54,
                      overlayColor: const Color.fromARGB(
                        255,
                        235,
                        169,
                        169,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    // onPressed: () => _showDeleteConfirmation(context, user),
                    onPressed: () => {},
                    icon: const Icon(Pixel.user, size: 16),
                    label: const Text('Account Status'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white54 : Colors.black54,
                      overlayColor: Colors.grey.withValues(alpha: 0.5),
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
