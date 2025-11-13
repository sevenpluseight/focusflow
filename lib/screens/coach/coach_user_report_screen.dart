import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachUserReportScreen extends StatefulWidget {
  final String userId;

  const CoachUserReportScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<CoachUserReportScreen> createState() => _CoachUserReportScreenState();
}

class _CoachUserReportScreenState extends State<CoachUserReportScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    // Find the user data that was already fetched by the CoachProvider
    // This is much faster than fetching from Firebase again
    final coachProvider = context.read<CoachProvider>();
    try {
      _user = coachProvider.connectedUsers.firstWhere(
        (u) => u.uid == widget.userId,
      );
    } catch (e) {
      _user = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('User not found.')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // We add an AppBar to this new screen
      appBar: AppBar(
        title: Text(_user!.username),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Overview, Focus Trend, etc. ---
            _buildReportButton(
              theme: theme,
              icon: Pixel.user,
              label: 'User Overview',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.listbox,
              label: 'Focus Trend',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.alert,
              label: 'Distraction Analysis',
              onTap: () {
                // TODO: Navigate to Distraction Analysis screen (Figure 29)
              },
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.flag,
              label: 'AI Risk Flags',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // --- "Cheer" and "Guide" Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Pixel.moodhappy),
                    label: const Text('Cheer'),
                    onPressed: () {
                      // TODO: Show "Send Cheer" modal (Figure 27)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Pixel.edit),
                    label: const Text('Guide'),
                    onPressed: () {
                      // TODO: Show "Recommend Guide" modal (Figure 28)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the buttons
  Widget _buildReportButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Pixel.chevronright, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}