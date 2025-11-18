import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/models.dart';

class ReportWithDetails {
  final ReportModel report;
  final DistractionLogModel log;
  final String userUsername;
  final String coachUsername;

  ReportWithDetails({
    required this.report,
    required this.log,
    required this.userUsername,
    required this.coachUsername,
  });
}

class ReportDistractLogProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ReportWithDetails> _pendingReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportWithDetails> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPendingReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reportSnap = await _db
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final List<ReportWithDetails> loadedDetails = [];

      final futures = reportSnap.docs.map((doc) async {
        final data = doc.data();

        final report = ReportModel(
          id: doc.id,
          reportedItemId: data['reportedItemId'] ?? '',
          reportedUserId: data['reportedUserId'] ?? '',
          coachId: data['coachId'] ?? '',
          createdAt: data['createdAt'] ?? Timestamp.now(),

          type: ReportType.distractionLog,

          status: ReportStatus.values.firstWhere(
            (e) =>
                e.toString().split('.').last == (data['status'] ?? 'pending'),
            orElse: () => ReportStatus.pending,
          ),
        );

        String userUsername = 'Unknown User';
        if (report.reportedUserId.isNotEmpty) {
          final userDoc = await _db
              .collection('users')
              .doc(report.reportedUserId)
              .get();
          userUsername = userDoc.data()?['username'] ?? 'Unknown User';
        }

        String coachUsername = 'Unknown Coach';
        if (report.coachId.isNotEmpty) {
          final coachDoc = await _db
              .collection('users')
              .doc(report.coachId)
              .get();
          coachUsername = coachDoc.data()?['username'] ?? 'Unknown Coach';
        }

        DistractionLogModel log;
        if (report.reportedUserId.isNotEmpty &&
            report.reportedItemId.isNotEmpty) {
          final logDoc = await _db
              .collection('users')
              .doc(report.reportedUserId)
              .collection('distractionLogs')
              .doc(report.reportedItemId)
              .get();

          if (logDoc.exists) {
            log = DistractionLogModel.fromFirestore(logDoc);
          } else {
            log = _createDeletedLog();
          }
        } else {
          log = _createDeletedLog();
        }

        return ReportWithDetails(
          report: report,
          log: log,
          userUsername: userUsername,
          coachUsername: coachUsername,
        );
      });

      loadedDetails.addAll(await Future.wait(futures));

      _pendingReports = loadedDetails;
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      _errorMessage = "Failed to load reports: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DistractionLogModel _createDeletedLog() {
    return DistractionLogModel(
      id: 'deleted',
      category: 'Deleted Log',
      createdAt: Timestamp.now(),
      note: 'Original log not found',
    );
  }

  Future<bool> resolveReport(String reportId, ReportStatus newStatus) async {
    try {
      await _db.collection('reports').doc(reportId).update({
        'status': newStatus.toString().split('.').last,
      });

      _pendingReports.removeWhere((item) => item.report.id == reportId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error updating report: $e");
      _errorMessage = "Failed to update status.";
      notifyListeners();
      return false;
    }
  }
}
