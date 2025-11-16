import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/screens/user/user.dart';

class FindCoachScreen extends StatefulWidget {
  const FindCoachScreen({Key? key}) : super(key: key);

  @override
  State<FindCoachScreen> createState() => _FindCoachScreenState();
}

class _FindCoachScreenState extends State<FindCoachScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachSearchProvider>().listenToApprovedCoaches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachSearchProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Coach'),
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: coachProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : coachProvider.approvedCoaches.isEmpty
              ? const Center(child: Text('No coaches found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coachProvider.approvedCoaches.length,
                  itemBuilder: (context, index) {
                    final coach = coachProvider.approvedCoaches[index];
                    final isPending = userProvider.pendingCoachIds.contains(coach.userId);
                    final isConnected = userProvider.user?.coachId == coach.userId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: StyledCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coach.fullName, // Display full name
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Expertise: ${coach.expertise}', // Display expertise
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bio: ${coach.bio}', // Display bio
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildConnectButton(
                                context: context,
                                isConnected: isConnected,
                                isPending: isPending,
                                coach: coach,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildConnectButton({
    required BuildContext context,
    required bool isConnected,
    required bool isPending,
    required CoachRequestModel coach,
  }) {
    if (isConnected) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserMessagesScreen(
                coachId: coach.userId,
                coachName: coach.fullName,
              ),
            ),
          );
        },
        child: const Text('View Messages'),
      );
    }

    if (isPending) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        onPressed: null,
        child: const Text('Pending'),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        try {
          await context.read<UserProvider>().sendConnectionRequest(coach.userId);
          if (!mounted) return;
          CustomSnackBar.show(
            context,
            message: 'Connection request sent to ${coach.fullName}!',
            type: SnackBarType.success,
          );
        } catch (e) {
          if (!mounted) return;
          CustomSnackBar.show(
            context,
            message: e.toString(),
            type: SnackBarType.error,
          );
        }
      },
      child: const Text('Connect'),
    );
  }
}
