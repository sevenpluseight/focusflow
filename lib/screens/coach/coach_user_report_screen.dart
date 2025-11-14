import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/coach/coach.dart';
import 'package:focusflow/screens/coach/widgets/widgets.dart';

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

  void _showCheerModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => CoachSendCheerModal(
        userId: user.uid,
        username: user.username,
      ),
    );
  }

  void _showGuideModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => CoachSendGuideModal(
        userId: user.uid,
        username: user.username,
      ),
    );
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachUserOverviewScreen(
                      userId: _user!.uid,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.listbox,
              label: 'Focus Trend',
              onTap: () 
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachFocusTrendScreen(
                      userId: _user!.uid,
                      username: _user!.username,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.alert,
              label: 'Distraction Analysis',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachDistractionLogScreen(
                      userId: _user!.uid,
                      username: _user!.username,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildReportButton(
              theme: theme,
              icon: Pixel.flag,
              label: 'AI Risk Flags',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachAiRiskFlagsScreen(
                      userId: _user!.uid,
                      username: _user!.username,
                    ),
                  ),
                );
              },
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
                       _showCheerModal(context, _user!);
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
                    icon: const Icon(Pixel.teach),
                    label: const Text('Guide'),
                    onPressed: () {
                      _showGuideModal(context, _user!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: theme.colorScheme.primary, width: 2),
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
            Icon(
              icon, 
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
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