import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CoachAiRiskFlagsScreen extends StatefulWidget {
  final String userId;
  final String username;

  const CoachAiRiskFlagsScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CoachAiRiskFlagsScreen> createState() => _CoachAiRiskFlagsScreenState();
}

class _CoachAiRiskFlagsScreenState extends State<CoachAiRiskFlagsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProvider>().fetchAiRiskFlags(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("AI Risk Flags for ${widget.username}"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Generated Insights',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            StyledCard(
              child: coachProvider.aiLoading
              ? const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing user data with AI...'),
                    ],
                  ),
                )
              : MarkdownBody(
                  data: coachProvider.aiInsights.isEmpty
                      ? 'No insights generated.'
                      : coachProvider.aiInsights,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    // Style for regular text
                    p: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    // Style for **bold** text
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    // Style for '## Heading'
                    h2: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    h2Padding: const EdgeInsets.only(top: 16, bottom: 4),
                    // Indent bullet points
                    listBullet: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    listBulletPadding: const EdgeInsets.only(
                      left: 4,
                      right: 8,
                      top: 4,
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
