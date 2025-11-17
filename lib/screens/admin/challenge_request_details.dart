import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/challenge_provider.dart';
import 'package:focusflow/widgets/widgets.dart'; // For Primary/Secondary Button
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChallengeRequestDetailsSheet extends StatelessWidget {
  final ChallengeModel request;

  const ChallengeRequestDetailsSheet({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ChallengeProvider>();

    final startDate = request.startDate!.toDate();
    final endDate = request.endDate!.toDate();
    final duration = endDate.difference(startDate).inDays;
    final createdDate = DateFormat(
      'MMM dd, yyyy',
    ).format(request.createdAt.toDate());

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.80,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  request.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submitted on $createdDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By Coach: ${request.coachId}', // TODO: Fetch coach name if needed
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: StyledCard(
                        title: "Focus Goal",
                        child: Text(
                          '${request.focusGoalHours} Hours',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StyledCard(
                        title: "Duration",
                        child: Text(
                          '$duration Days',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  "Description",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(request.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        onPressed: () async {
                          final success = await provider.rejectChallenge(
                            request.id,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            CustomSnackBar.show(
                              context,
                              message: 'Challenge rejected',
                            );
                            Navigator.pop(context);
                          } else {
                            CustomSnackBar.show(
                              context,
                              message: 'Error: ${provider.errorMessage}',
                              type: SnackBarType.error,
                            );
                          }
                        },

                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [SizedBox(width: 8), Text('Reject')],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final success = await provider.approveChallenge(
                            request.id,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            CustomSnackBar.show(
                              context,
                              message: 'Challenge approved!',
                            );
                            Navigator.pop(context);
                          } else {
                            CustomSnackBar.show(
                              context,
                              message: 'Error: ${provider.errorMessage}',
                              type: SnackBarType.error,
                            );
                          }
                        },
                        child: const Text("Approve"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
