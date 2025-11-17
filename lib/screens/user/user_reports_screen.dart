import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:focusflow/models/distraction_log_model.dart';
import 'package:focusflow/providers/distraction_provider.dart';
import 'package:focusflow/providers/report_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class UserReportsScreen extends StatelessWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

  // Helper widget to display image from URL or Base64
  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover);
    } else if (imageUrl != 'none') {
      try {
        final decodedBytes = base64Decode(imageUrl);
        return Image.memory(decodedBytes, width: 50, height: 50, fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 50);
      }
    }
    return const SizedBox.shrink(); // Return empty space if no image
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final bool hasReport = reportProvider.focusSummaryReport != null &&
        reportProvider.distractionBreakdownReport != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Focus Report'),
        centerTitle: false,
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportProvider.errorMessage != null
              ? Center(child: Text(reportProvider.errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reportProvider.isAnalyzing)
                          const Center(child: CircularProgressIndicator())
                        else if (hasReport)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reportProvider.reportUpdatedAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Last updated: ${DateFormat.yMMMd().add_jm().format(reportProvider.reportUpdatedAt!)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              StyledCard(
                                title: 'Focus Summary',
                                child: Text(reportProvider.focusSummaryReport!),
                              ),
                              const SizedBox(height: 16),
                              StyledCard(
                                title: 'Distraction Breakdown',
                                child: Text(
                                    reportProvider.distractionBreakdownReport!),
                              ),
                            ],
                          )
                        else
                          const Center(child: Text('No report available. Pull down to refresh.')),
                        
                        const SizedBox(height: 24),

                        // Real-time Distraction Logs
                        StreamBuilder<List<DistractionLogModel>>(
                          stream: context.watch<DistractionProvider>().distractionLogsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const StyledCard(
                                title: 'Recent Distractions',
                                child: Text('No distractions logged yet.'),
                              );
                            }
                            final logs = snapshot.data!;
                            return StyledCard(
                              title: 'Recent Distractions',
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  return ListTile(
                                    title: Text(log.category),
                                    subtitle: Text(log.note ?? ''),
                                    trailing: Text(DateFormat.yMd().add_jm().format(log.createdAt.toDate())),
                                    leading: log.imageUrl != null ? _buildImage(log.imageUrl!) : null,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reportProvider.forceAnalyzeWeeklyReport();
        },
        child: const Icon(Pixel.reload),
      ),
    );
  }
}
