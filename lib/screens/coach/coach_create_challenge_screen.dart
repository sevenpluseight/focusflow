import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachCreateChallengeScreen extends StatefulWidget {
  const CoachCreateChallengeScreen({super.key});

  @override
  State<CoachCreateChallengeScreen> createState() => _CoachCreateChallengeScreenState();
}

class _CoachCreateChallengeScreenState extends State<CoachCreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialDate) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (date == null) return null;
  if (!context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
  );

  if (!context.mounted) return null;
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date & Time';
    return DateFormat('MMM d, yyyy - h:mm a').format(date);
  }

  Future<void> _submitChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        CustomSnackBar.show(context, message: 'Please select a start and end date', type: SnackBarType.error);
      }
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      if (mounted) {
        CustomSnackBar.show(context, message: 'End date must be after the start date', type: SnackBarType.error);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final coachProvider = context.read<CoachProvider>();

      await coachProvider.submitChallengeForApproval(
        name: _nameController.text,
        focusGoalHours: int.parse(_goalController.text),
        description: _descriptionController.text,
        startDate: Timestamp.fromDate(_startDate!),
        endDate: Timestamp.fromDate(_endDate!),
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
              
              _buildDateTimePicker(
                theme: theme,
                label: 'Start Date & Time',
                icon: Pixel.calendar,
                date: _startDate,
                onTap: () async {
                  final newDate = await _pickDateTime(context, _startDate);
                  if (newDate != null) setState(() => _startDate = newDate);
                },
              ),
              const SizedBox(height: 16),
              
              _buildDateTimePicker(
                theme: theme,
                label: 'End Date & Time',
                icon: Pixel.calendar,
                date: _endDate,
                onTap: () async {
                  final newDate = await _pickDateTime(context, _endDate ?? _startDate);
                  if (newDate != null) setState(() => _endDate = newDate);
                },
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
                    : const Text('Submit for Approval'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required ThemeData theme,
    required String label,
    required IconData icon,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    // This custom picker stays the same, as it's not a text field
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.inputDecorationTheme.enabledBorder!.borderSide.color)
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null ? label : _formatDate(date),
                style: TextStyle(
                  fontSize: 16,
                  color: date == null ? theme.textTheme.bodyMedium?.color : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const Icon(Pixel.chevronright, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}