import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/gemini_service.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DailyProgressModel> _weeklyFocusData = [];
  List<DailyProgressModel> get weeklyFocusData => _weeklyFocusData;

  List<DistractionLogModel> _weeklyDistractionData = [];
  List<DistractionLogModel> get weeklyDistractionData => _weeklyDistractionData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _focusSummaryReport;
  String? get focusSummaryReport => _focusSummaryReport;

  String? _distractionBreakdownReport;
  String? get distractionBreakdownReport => _distractionBreakdownReport;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  ReportProvider() {
    fetchWeeklyReportData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAnalyzing(bool value) {
    _isAnalyzing = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchWeeklyReportData() async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User not logged in.');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userSnapshot = await userDocRef.get();
      final userData = userSnapshot.data();

      final savedReport = userData?['weeklyReport'] as Map<String, dynamic>?;
      final savedTimestamp = savedReport?['updatedAt'] as Timestamp?;

      if (savedTimestamp != null) {
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

        if (savedTimestamp.toDate().isAfter(startOfWeekDate)) {
          _focusSummaryReport = savedReport?['focusSummary'];
          _distractionBreakdownReport = savedReport?['distractionBreakdown'];
          _setLoading(false);
          return;
        }
      }

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final focusSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyProgress')
          .where('date', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      _weeklyFocusData = focusSnapshot.docs
          .map((doc) => DailyProgressModel.fromFirestore(doc))
          .toList();

      final distractionSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('distractionLogs')
          .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      _weeklyDistractionData = distractionSnapshot.docs
          .map((doc) => DistractionLogModel.fromFirestore(doc))
          .toList();

      await _analyzeAndSaveWeeklyReport();
    } catch (e) {
      _setError('Error fetching weekly report data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _analyzeAndSaveWeeklyReport() async {
    _setAnalyzing(true);
    _focusSummaryReport = null;
    _distractionBreakdownReport = null;

    try {
      final focusSummary =
          'Total focus time this week: ${weeklyFocusData.fold<int>(0, (prev, e) => prev + e.focusedMinutes)} minutes';
      final distractionSummary =
          'Total distractions this week: ${weeklyDistractionData.length}';

      final prompt = """
        Generate a weekly focus report for the user. Provide the "Focus Summary" and "Distraction Breakdown" as two separate sections, delimited by "---BREAK---".
        
        Focus Summary:
        $focusSummary
        
        Distraction Breakdown:
        $distractionSummary
        
        Provide a concise, user-friendly analysis for each section. Avoid using markdown formatting like bolding (**).
        """;

      final analysis = await GeminiService.generateText(prompt);
      final parts = analysis.split('---BREAK---');

      if (parts.length == 2) {
        _focusSummaryReport = parts[0].trim();
        _distractionBreakdownReport = parts[1].trim();
      } else {
        _focusSummaryReport = 'Error: Could not parse focus summary.';
        _distractionBreakdownReport = 'Error: Could not parse distraction breakdown.';
      }

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'weeklyReport': {
            'focusSummary': _focusSummaryReport,
            'distractionBreakdown': _distractionBreakdownReport,
            'updatedAt': Timestamp.now(),
          }
        });
      }
    } catch (e) {
      _focusSummaryReport = 'Error generating analysis: $e';
      _distractionBreakdownReport = 'Error generating analysis: $e';
    } finally {
      _setAnalyzing(false);
    }
  }

  Future<void> forceAnalyzeWeeklyReport() async {
    await _analyzeAndSaveWeeklyReport();
  }
}
