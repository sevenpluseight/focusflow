import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';

class CoachCreateChallengeScreen extends StatefulWidget {
  const CoachCreateChallengeScreen({Key? key}) : super(key: key);

  @override
  State<CoachCreateChallengeScreen> createState() => _CoachCreateChallengeScreenState();
}

class _CoachCreateChallengeScreenState extends State<CoachCreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _goalController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

Future<void> _submitChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }

    setState(() => _isLoading = true);

    try {
      final coachProvider = context.read<CoachProvider>();
      
      await coachProvider.submitChallengeForApproval(
        name: _nameController.text,
        durationDays: int.parse(_durationController.text),
        focusGoalHours: int.parse(_goalController.text),
        description: _descriptionController.text,
      );

      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Challenge submitted for approval!',
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create a Challenge'),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
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
                labelText: 'Challenge Name',
                icon: Pixel.edit,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _durationController,
                labelText: 'Duration (in days)',
                icon: Pixel.calendar,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a duration' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _goalController,
                labelText: 'Focus Goal (in hours)',
                icon: Pixel.clock,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a goal' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                icon: Pixel.editbox,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: _isLoading ? null : _submitChallenge,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        'Submit for Approval',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}