import 'package:flutter/material.dart';
import 'package:focusflow/providers/report_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class UserReportsScreen extends StatelessWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Weekly Focus Report'),
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
                        else if (reportProvider.focusSummaryReport != null &&
                            reportProvider.distractionBreakdownReport != null)
                          Column(
                            children: [
                              StyledCard(
                                title: 'Focus Summary',
                                child: Text(reportProvider.focusSummaryReport!),
                              ),
                              const SizedBox(height: 16),
                              StyledCard(
                                title: 'Distraction Breakdown',
                                child: Text(reportProvider.distractionBreakdownReport!),
                              ),
                            ],
                          )
                        else
                          const Center(child: Text('No report available.')),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reportProvider.forceAnalyzeWeeklyReport();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
