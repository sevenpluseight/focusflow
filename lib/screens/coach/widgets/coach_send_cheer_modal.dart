import 'package:flutter/material.dart';
import 'package:focusflow/models/message_model.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CoachSendCheerModal extends StatefulWidget {
  final String userId;
  final String username;

  const CoachSendCheerModal({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CoachSendCheerModal> createState() => _CoachSendCheerModalState();
}

class _CoachSendCheerModalState extends State<CoachSendCheerModal> {
  final _customCheerController = TextEditingController();
  bool _isLoading = false;

  final List<String> _predefinedCheers = [
    "You're doing great, keep it up!",
    "Awesome focus session!",
    "Don't give up, you've got this!",
    "Great consistency!",
  ];

  @override
  void dispose() {
    _customCheerController.dispose();
    super.dispose();
  }

  Future<void> _sendCheer(String cheerText) async {
    if (cheerText.isEmpty) return;

    setState(() => _isLoading = true);
    final coachProvider = context.read<CoachProvider>();

    try {
      await coachProvider.sendMessage(
        userId: widget.userId,
        text: cheerText,
        type: MessageType.cheer,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the modal
      CustomSnackBar.show(
        context,
        message: 'Cheer sent to ${widget.username}!',
        type: SnackBarType.success,
      );

    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Failed to send cheer: $e',
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Send Cheer to ${widget.username}',
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
              
              ..._predefinedCheers.map((cheer) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => _sendCheer(cheer),

                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    cheer,
                  ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _customCheerController,
                labelText: 'Custom Cheer',
              ),
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _sendCheer(_customCheerController.text),
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