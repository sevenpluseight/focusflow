import 'package:flutter/material.dart';
import 'package:focusflow/models/coach_request_model.dart';
import 'package:focusflow/providers/coach_request_provider.dart';
import 'package:focusflow/widgets/widgets.dart'; // For Primary/Secondary Button
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CoachRequestDetailsSheet extends StatelessWidget {
  final CoachRequestModel request;

  const CoachRequestDetailsSheet({super.key, required this.request});

  // Helper to launch URL
  void _launchURL(BuildContext context, String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        CustomSnackBar.show(
          context,
          message: 'Could not launch $url',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<CoachRequestProvider>();

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

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Pixel.mail),
                      color: Colors.white,
                      iconSize: 36.0,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Coach Request",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 24,
                    child: const Icon(Pixel.user),
                  ),
                  title: Text(
                    request.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    request.username,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 32),

                _buildDetailCard(
                  theme,
                  icon: Pixel.suitcase,
                  title: "Expertise",
                  content: request.expertise,
                ),
                const SizedBox(height: 16),
                _buildDetailCard(
                  theme,
                  icon: Pixel.infobox,
                  title: "Bio",
                  content: request.bio,
                ),
                const SizedBox(height: 16),
                if (request.portfolioLink != null &&
                    request.portfolioLink!.isNotEmpty)
                  _buildDetailCard(
                    theme,
                    icon: Pixel.externallink,
                    title: "Portfolio",
                    content: request.portfolioLink!,
                    isLink: true,
                    onTap: () => _launchURL(context, request.portfolioLink),
                  ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        onPressed: () async {
                          final success = await provider.rejectCoachRequest(
                            request.id,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            CustomSnackBar.show(
                              context,
                              message: 'Request rejected',
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
                          children: [Text('Reject')],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final success = await provider.approveCoachRequest(
                            request,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            CustomSnackBar.show(
                              context,
                              message: 'Coach approved!',
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

  // Helper for displaying details
  Widget _buildDetailCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return StyledCard(
      titleWidget: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: isLink ? onTap : null,
        child: Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isLink
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.8),
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
