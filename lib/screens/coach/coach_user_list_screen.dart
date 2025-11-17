import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
// import 'package:focusflow/theme/app_theme.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/screens/coach/coach.dart';

class CoachUserListScreen extends StatefulWidget {
  const CoachUserListScreen({Key? key}) : super(key: key);
  
  @override
  State<CoachUserListScreen> createState() => _CoachUserListScreenState();
}

class _CoachUserListScreenState extends State<CoachUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final authProvider = context.read<AuthProvider>();
    final coachProvider = context.read<CoachProvider>();
    final coachId = authProvider.user?.uid ?? '';
    await coachProvider.fetchConnectedUsers(coachId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;
    
    // Watch the provider here
    final coachProvider = context.watch<CoachProvider>();

    // Filter users based on search query
    final filteredUsers = coachProvider.connectedUsers.where((user) {
      final username = user.username.toLowerCase();
      return username.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Search by username...',
              icon: Pixel.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          _UserListView(
            isLoading: coachProvider.isLoading,
            filteredUsers: filteredUsers,
          ),
        ],
      ),
    );
  }
}

class _UserListView extends StatelessWidget {
  final bool isLoading;
  final List<UserModel> filteredUsers;

  const _UserListView({
    required this.isLoading,
    required this.filteredUsers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachProvider>();

    if (coachProvider.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (filteredUsers.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No connected users found.',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final minutes = coachProvider.todayFocusMinutes[user.uid] ?? 0;
          return _buildUserReportCard(context, theme, user, minutes);
        },
      ),
    );
  }

  // This widget builds the card using a real UserModel
  Widget _buildUserReportCard(BuildContext context, ThemeData theme, UserModel user, int minutes) {
    // --- Status Logic ---
    String status = "Active";
    Color statusColor;

    if ((user.currentStreak ?? 0) == 0) {
      status = "At Risk";
      statusColor = theme.colorScheme.tertiary;
    } else {
      status = "Active";
      statusColor = theme.colorScheme.primary;
    }

    String focusText;
    if (minutes == 0) {
      focusText = '0h';
    } else if (minutes < 60) {
      focusText = '${minutes}m';
    } else {
      // e.g., 90 minutes = 1.5h
      focusText = '${(minutes / 60).toStringAsFixed(1)}h';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: StyledCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize:18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus: $focusText',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Streak: ${user.currentStreak ?? 0} days',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: (status == 'At Risk' || status == "Active")
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoachUserReportScreen(
                          userId: user.uid,
                        )
                      ),
                    );  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, // Use theme color
                    foregroundColor: Colors.black, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(110, 44),
                  ),
                  child: const Text('View Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}