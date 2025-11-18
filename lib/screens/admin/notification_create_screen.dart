import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/notification_provider.dart'; // Import provider
import 'package:focusflow/widgets/widgets.dart'; // Includes all your reusable widgets
import 'package:pixelarticons/pixelarticons.dart';

class AdminNotifyScreen extends StatefulWidget {
  const AdminNotifyScreen({super.key});

  @override
  State<AdminNotifyScreen> createState() => _AdminNotifyScreenState();
}

class _AdminNotifyScreenState extends State<AdminNotifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedTarget = 'all';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<NotificationProvider>();
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    final success = await provider.sendNotification(
      title: title,
      message: message,
      target: _selectedTarget,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.show(
        context,
        message: 'Notification sent successfully!',
        type: SnackBarType.success,
        position: SnackBarPosition.top,
      );
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedTarget = 'all';
      });
    } else {
      CustomSnackBar.show(
        context,
        message: 'Failed to send notification: ${provider.errorMessage}',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Pixel.notification, size: 28, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Send Notification',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Send To:',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTargetButton('all', 'All Users')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTargetButton('coach', 'Coaches')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTargetButton('user', 'Users')),
                ],
              ),
              const SizedBox(height: 24),

              // --- End of Modification ---
              CustomTextFormField(
                controller: _titleController,
                labelText: 'Notification Title',
                icon: Pixel.edit, // Changed icon
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _messageController,
                labelText: 'Message',
                icon: Pixel.editbox,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: provider.isLoading ? null : _submitNotification,
                child: provider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Send Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetButton(String value, String label) {
    final isSelected = _selectedTarget == value;
    final theme = Theme.of(context);

    if (isSelected) {
      return PrimaryButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: theme.colorScheme.primary,
          disabledForegroundColor: Colors.black,
        ),
        child: Text(label),
      );
    }
    return SecondaryButton(
      onPressed: () {
        setState(() {
          _selectedTarget = value;
        });
      },
      child: Text(label),
    );
  }
}
