import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/models/models.dart';

class ReportDetailsSheet extends StatefulWidget {
  final ReportWithDetails details;

  const ReportDetailsSheet({super.key, required this.details});

  @override
  State<ReportDetailsSheet> createState() => _ReportDetailsSheetState();
}

class _ReportDetailsSheetState extends State<ReportDetailsSheet> {
  bool _isBlurred = true;
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    final imageUrl = widget.details.log.imageUrl;
    if (imageUrl != null &&
        imageUrl != 'none' &&
        !imageUrl.startsWith('http')) {
      try {
        _decodedBytes = base64Decode(imageUrl);
      } catch (e) {
        debugPrint('Error decoding image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final log = widget.details.log;
    final provider = context.read<ReportDistractLogProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.imageUrl != null && log.imageUrl != 'none')
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 270,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: _buildImage(log.imageUrl!),
                              ),

                              Positioned.fill(
                                child: IgnorePointer(
                                  ignoring: !_isBlurred,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: _isBlurred ? 1.0 : 0.0,
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 15,
                                        sigmaY: 15,
                                      ),
                                      child: Container(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (_isBlurred)
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    child: SecondaryButton(
                                      onPressed: () {
                                        setState(() {
                                          _isBlurred = false;
                                        });
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Pixel.eye),
                                          SizedBox(width: 8),
                                          Text("View Image"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        color: theme.cardColor,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Pixel.image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("No image attached"),
                          ],
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.details.userUsername}'s Log",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Reported by ${widget.details.coachUsername}",
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        StyledCard(
                          title: "Category",
                          child: Text(
                            log.category,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StyledCard(
                          title: "User Note",
                          child: Text(
                            (log.note == null || log.note!.isEmpty)
                                ? "No note."
                                : log.note!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            onPressed: () async {
                              await _handleAction(
                                context,
                                provider,
                                ReportStatus.dismissed,
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('Dismiss')],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () async {
                              await _handleAction(
                                context,
                                provider,
                                ReportStatus.reviewed,
                              );
                            },
                            child: const Text("Mark Reviewed"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    ReportDistractLogProvider provider,
    ReportStatus status,
  ) async {
    final success = await provider.resolveReport(
      widget.details.report.id,
      status,
    );

    if (!context.mounted) return;

    if (success) {
      CustomSnackBar.show(
        context,
        message: status == ReportStatus.dismissed
            ? 'Report dismissed'
            : 'Marked as reviewed',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else {
      CustomSnackBar.show(
        context,
        message: 'Error: ${provider.errorMessage}',
        type: SnackBarType.error,
      );
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    } else if (_decodedBytes != null) {
      return Image.memory(_decodedBytes!, fit: BoxFit.cover);
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}
