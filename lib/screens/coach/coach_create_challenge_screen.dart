import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitChallenge() {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      final name = _nameController.text;
      final duration = int.parse(_durationController.text);
      final goal = int.parse(_goalController.text);
      final description = _descriptionController.text;

      // TODO: Add logic to save this challenge to Firebase
      // It should be sent to the Admin for approval [cite: 1363]
      
      print('Submitting Challenge: $name, $duration days, $goal hours, $description');

      // Go back to the previous screen after submission
      Navigator.of(context).pop();
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
              _buildTextFormField(
                controller: _nameController,
                label: 'Challenge Name',
                icon: Pixel.edit,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _durationController,
                label: 'Duration (in days)',
                icon: Pixel.calendar,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a duration' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _goalController,
                label: 'Focus Goal (in hours)',
                icon: Pixel.clock,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a goal' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                icon: Pixel.editbox,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}