import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachApplicationScreen extends StatefulWidget {
  const CoachApplicationScreen({Key? key}) : super(key: key);

  @override
  State<CoachApplicationScreen> createState() => _CoachApplicationScreenState();
}

class _CoachApplicationScreenState extends State<CoachApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _bioController = TextEditingController();
  final _portfolioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _expertiseController.dispose();
    _bioController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }
    
    setState(() => _isLoading = true);
    final userProvider = context.read<UserProvider>();
    
    try {
      await userProvider.submitCoachApplication(
        fullName: _nameController.text,
        expertise: _expertiseController.text,
        bio: _bioController.text,
        portfolioLink: _portfolioController.text,
      );
      
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Application submitted! Admin will review it soon.',
        type: SnackBarType.success,
      );
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: e.toString(),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Coach Application'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Full Name',
                icon: Pixel.user,
                validator: (val) => val!.isEmpty ? 'Please enter your full name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _expertiseController,
                labelText: 'Area of Expertise (e.g., Productivity, Study)',
                icon: Pixel.book,
                validator: (val) => val!.isEmpty ? 'Please enter your expertise' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _bioController,
                labelText: 'Short Bio',
                icon: Pixel.editbox,
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Please enter a short bio' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _portfolioController,
                labelText: 'Portfolio Link (Optional)',
                icon: Pixel.link,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}