import 'package:flutter/material.dart';
import 'package:focusflow/models/coach_request_model.dart';
import 'package:focusflow/providers/coach_request_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/admin/admin.dart'; // Import new screen

class CoachRequestsSection extends StatelessWidget {
  const CoachRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StyledCard(
      padding: EdgeInsets.zero,

      child: StreamBuilder<List<CoachRequestModel>>(
        stream: context
            .watch<CoachRequestProvider>()
            .getPendingRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          return Column(
            children: [
              if (requests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No pending coach requests.')),
                )
              else
                ListView.builder(
                  itemCount: requests.take(3).length, // Show top 3
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return _buildUserRequestTile(requests[index], context);
                  },
                ),

              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withOpacity(0.2),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminCoachRequestsScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(24.0),
                    foregroundColor: theme.colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text(
                    'See All Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserRequestTile(
    CoachRequestModel request,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(Pixel.user, color: theme.colorScheme.primary),
          ),
          title: Text(
            request.fullName,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(request.username, style: theme.textTheme.bodyMedium),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => CoachRequestDetailsSheet(request: request),
            );
          },
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.scaffoldBackgroundColor,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
