import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/services.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/utils/size_config.dart'; // Import SizeConfig

class MoodTrackerScreen extends StatefulWidget {
  final String sessionId;

  const MoodTrackerScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  _MoodTrackerScreenState createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? _selectedMood;
  final _notesController = TextEditingController();
  final _moodService = MoodService();
  bool _isLoading = false;

  final List<String> _moods = ['😢', '😟', '😐', '🙂', '😄'];
  final Map<String, String> _moodDescriptions = {
    '😢': 'Very Sad',
    '😟': 'Sad',
    '😐': 'Neutral',
    '🙂': 'Happy',
    '😄': 'Very Happy',
  };

  void _submitMood() async {
    if (_selectedMood == null) {
      CustomSnackBar.show(
        context,
        message: 'Please select a mood.',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final moodDescription = _moodDescriptions[_selectedMood!] ?? 'Unknown';
      final notes = _notesController.text.trim().isEmpty
          ? 'none'
          : _notesController.text.trim();

      final moodLog = MoodLogModel(
        moodChosen: moodDescription,
        notes: notes,
        createdAt: DateTime.now(),
        sessionId: widget.sessionId,
      );
      await _moodService.saveMoodLog(moodLog);

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Mood saved successfully!',
          type: SnackBarType.success,
          position: SnackBarPosition.top,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to save mood: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('How do you feel?'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.wp(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: SizeConfig.hp(3)),
            Text(
              'Select your mood',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: SizeConfig.hp(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(SizeConfig.wp(3)),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          mood,
                          style: TextStyle(fontSize: SizeConfig.font(4.5)),
                        ),
                      ),
                      SizedBox(height: SizeConfig.hp(1)),
                      Text(
                        _moodDescriptions[mood] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: SizeConfig.hp(6)),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Add a note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              maxLines: 3,
              cursorColor: theme.colorScheme.primary,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            SizedBox(height: SizeConfig.hp(3)),
            PrimaryButton(
              text: 'Submit',
              onPressed: _isLoading ? null : _submitMood,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
