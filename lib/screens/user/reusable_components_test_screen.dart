import 'package:flutter/material.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';

class ReusableComponentsTestScreen extends StatelessWidget {
  const ReusableComponentsTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textFieldController = TextEditingController();
    final TextEditingController _formFieldController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable Components Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Button
            const Text(
              'Primary Button:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'Primary Button Pressed!',
                  type: SnackBarType.info,
                );
              },
              child: const Text('Primary Action'),
            ),
            const SizedBox(height: 16),

            // Secondary Button
            const Text(
              'Secondary Button:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'Secondary Button Pressed!',
                  type: SnackBarType.info,
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Pixel.warningbox),
                  SizedBox(width: 8),
                  Text('Secondary Action'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Custom Text Field
            const Text(
              'Custom Text Field:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _textFieldController,
              labelText: 'Enter text here',
              icon: Pixel.edit,
            ),
            const SizedBox(height: 16),

            // Custom Text Form Field
            const Text(
              'Custom Text Form Field:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Form(
              child: CustomTextFormField(
                controller: _formFieldController,
                labelText: 'Enter validated text',
                icon: Pixel.check,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Styled Card
            const Text(
              'Styled Card:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StyledCard(
              hasBorder: false,
              title: 'Flexible Card',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'This card is flexible and scrollable if content overflows. '
                    'It adapts to the screen size and respects theme colors for title text.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info Modal
            const Text(
              'Info Modal (via button):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return InfoModal(
                      title: 'Information',
                      message: 'This is a reusable info modal!',
                      onClose: () => Navigator.of(context).pop(),
                    );
                  },
                );
              },
              child: const Text('Show Info Modal'),
            ),
            const SizedBox(height: 16),

            // Custom SnackBar
            const Text(
              'Custom SnackBar (via button):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'This is a success snackbar!',
                  type: SnackBarType.success,
                );
              },
              child: const Text('Show Success SnackBar'),
            ),
            const SizedBox(height: 16),

            // Animated Nav Bar Item (conceptual)
            const Text(
              'Animated Nav Bar Item (conceptual):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'AnimatedNavBarItem is designed for use within a custom navigation bar. '
              'Its functionality is best observed in that context.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
