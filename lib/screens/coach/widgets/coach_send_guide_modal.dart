import 'package:flutter/material.dart';
import 'package:focusflow/models/message_model.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CoachSendGuideModal extends StatefulWidget {
  final String userId;
  final String username;

  const CoachSendGuideModal({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CoachSendGuideModal> createState() => _CoachSendGuideModalState();
}

class _CoachSendGuideModalState extends State<CoachSendGuideModal> {
  final _customGuideController = TextEditingController();
  bool _isLoading = false;

  // You can pre-define common strategies
  final List<String> _suggestedStrategies = [
    "Try breaking your task into smaller 25-min sessions.",
    "Make sure to take a 5-minute break after each session.",
    "Try to identify your biggest distraction and remove it.",
  ];

  @override
  void dispose() {
    _customGuideController.dispose();
    super.dispose();
  }

  Future<void> _sendGuide(String guideText) async {
    if (guideText.isEmpty) return;

    setState(() => _isLoading = true);
    final coachProvider = context.read<CoachProvider>();

    try {
      await coachProvider.sendMessage(
        userId: widget.userId,
        text: guideText,
        type: MessageType.guide,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the modal
      CustomSnackBar.show(
        context,
        message: 'Guide sent to ${widget.username}!',
        type: SnackBarType.success,
      );

    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Failed to send guide: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? theme.cardColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recommended Guides',
                    style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._suggestedStrategies.map((guide) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => _sendGuide(guide),
                style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    guide,
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _customGuideController,
              decoration: InputDecoration(
                labelText: 'Custom Guide',
                fillColor: theme.scaffoldBackgroundColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _sendGuide(_customGuideController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}