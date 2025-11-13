import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/theme/app_theme.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/models/models.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: 'Search by username...',
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                prefixIcon: Icon(
                  Pixel.search,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),

          // **--- THIS IS THE FIX ---**
          // We pass the data to a new, separate widget.
          // This isolates the ListView from the setState calls
          // triggered by the TextField.
          _UserListView(
            isLoading: coachProvider.isLoading,
            filteredUsers: filteredUsers,
          ),
        ],
      ),
    );
  }
}


// --- NEW WIDGET ---
// This widget is now separate and will not conflict
// with the keyboard resizing.

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

    if (isLoading) {
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
        // This is a nice-to-have: hides the keyboard when you scroll
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildUserReportCard(theme, user);
        },
      ),
    );
  }

  // This widget builds the card using a real UserModel
  Widget _buildUserReportCard(ThemeData theme, UserModel user) {
    // --- Status Logic ---
    String status = "Active";
    Color statusColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    if ((user.currentStreak ?? 0) == 0) {
      status = "At Risk";
      statusColor = Colors.orangeAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus: (todo)h',
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
                      fontWeight: status == 'At Risk'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Specific User's Report (Figure 26)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Use theme color
                foregroundColor: Colors.black, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 44),
              ),
              child: const Text('View Report'),
            ),
          ],
        ),
      ),
    );
  }
}