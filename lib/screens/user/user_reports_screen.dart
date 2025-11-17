import 'package:flutter/material.dart';
import 'package:focusflow/providers/report_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class UserReportsScreen extends StatelessWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

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
