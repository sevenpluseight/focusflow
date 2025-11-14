import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("AI Risk Flags for ${widget.username}"),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                : MarkdownBody( // <-- Changed from Text to MarkdownBody
                  data: coachProvider.aiInsights.isEmpty
                      ? 'No insights generated.'
                      : coachProvider.aiInsights,
                  styleSheet: MarkdownStyleSheet(
                    // Customize text styles here if needed
                    p: TextStyle(fontSize: 16, height: 1.5, color: theme.textTheme.bodyMedium?.color),
                    strong: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    listBullet: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    // You can add more customizations for h1, h2, ul, li, etc.
                  ),
                ),
          ),
        ),
      ),
    );
  }
}