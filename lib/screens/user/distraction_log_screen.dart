import 'dart:io';
import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class DistractionLogScreen extends StatefulWidget {
  const DistractionLogScreen({Key? key}) : super(key: key);

  @override
  _DistractionLogScreenState createState() => _DistractionLogScreenState();
}

class _DistractionLogScreenState extends State<DistractionLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DistractionProvider>(context, listen: false).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log a Distraction'),
        centerTitle: false,
      ),
      body: Consumer<DistractionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a screenshot (optional)', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (provider.imageFile != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(provider.imageFile!.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                        onPressed: () => provider.clearImage(),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => provider.showImageSourceDialog(context),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Pixel.downasaur, size: 48, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('Add Something', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('What distracted you?', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: provider.categories.map((category) {
                    final isSelected = provider.selectedCategory == category;
                    return Opacity(
                      opacity: provider.selectedCategory == null || isSelected ? 1.0 : 0.5,
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.selectCategory(selected ? category : null);
                        },
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: provider.notesController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                                PrimaryButton(
                                  text: 'Log Distraction',
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          final errorMessage = await context.read<DistractionProvider>().submitLog();
                                          if (context.mounted) {
                                            if (errorMessage == null) {
                                              CustomSnackBar.show(
                                                context,
                                                message: 'Distraction logged successfully!',
                                                type: SnackBarType.success,
                                                position: SnackBarPosition.top,
                                              );
                                              Navigator.of(context).pop();
                                            } else {
                                              CustomSnackBar.show(
                                                context,
                                                message: errorMessage,
                                                type: SnackBarType.error,
                                              );
                                            }
                                          }
                                        },
                                  isLoading: provider.isLoading,
                                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
