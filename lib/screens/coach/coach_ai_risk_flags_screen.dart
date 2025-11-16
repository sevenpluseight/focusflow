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
    super.key,
    required this.userId,
    required this.username,
  });

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
    final textColor = theme.colorScheme.onSurface;
    final insights = coachProvider.aiInsights;

    // -------- SPLIT THE MARKDOWN INTO 2 PARTS --------
    String riskFlags = "";
    String positiveInsights = "";

    if (insights.contains("## AI Risk Flags")) {
      final sections = insights.split("## AI Risk Flags");
      if (sections.length > 1) {
        final afterRisk = sections[1];
        if (afterRisk.contains("## Positive Insights")) {
          final split = afterRisk.split("## Positive Insights");
          riskFlags = split[0].trim();
          positiveInsights = split[1].trim();
        } else {
          riskFlags = afterRisk.trim();
        }
      }
    }

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
            // ---------- BIG TITLE ----------
            Text(
              'AI Generated Insights',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 20),

            // ------------ CARD 1: AI RISK FLAGS -------------
            StyledCard(
              titleWidget: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center, // ensures icon aligns with text
                children: [
                  const Icon(Pixel.flag, color: Colors.red), // example icon
                  const SizedBox(width: 8),
                  Text(
                    "AI Risk Flags",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor 
                    ),
                  ),
                ],
              ),
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
                      data: riskFlags.isEmpty ? "No risk flags detected." : riskFlags,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color, // descriptions grayish
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor, 
                        ),
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
            const SizedBox(height: 24),

            // ------------ CARD 2: POSITIVE INSIGHTS -------------
            StyledCard(
              titleWidget: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center, // ensures icon aligns with text
                children: [
                  const Icon(Pixel.heart, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "Positive Insights",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
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
                      data: positiveInsights.isEmpty
                          ? "No positive insights available."
                          : positiveInsights,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
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