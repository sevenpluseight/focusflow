import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:focusflow/models/models.dart';

class AdminAnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DailyProgressModel> _globalFocusHistory = [];
  List<DailyProgressModel> get globalFocusHistory => _globalFocusHistory;

  Map<String, int> _globalDistractionStats = {};
  Map<String, int> get globalDistractionStats => _globalDistractionStats;

  String get todayFocusHours {
    if (_globalFocusHistory.isEmpty) return "0.0";

    final now = DateTime.now();
    final todayKey =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    try {
      final todayEntry = _globalFocusHistory.firstWhere(
        (e) => e.date == todayKey,
      );
      return (todayEntry.focusedMinutes / 60).toStringAsFixed(1);
    } catch (e) {
      return "0.0";
    }
  }

  String get last7DaysFocusHours {
    if (_globalFocusHistory.isEmpty) return "0.0";

    final count = _globalFocusHistory.length;
    final takeCount = count < 7 ? count : 7;

    final last7 = _globalFocusHistory.sublist(count - takeCount, count);

    final totalMinutes = last7.fold(
      0,
      (sum, item) => sum + item.focusedMinutes,
    );
    return (totalMinutes / 60).toStringAsFixed(1);
  }

  List<Map<String, String>> get topDistractionsFormatted {
    if (_globalDistractionStats.isEmpty) return [];

    final totalCount = _globalDistractionStats.values.fold(
      0,
      (sum, v) => sum + v,
    );
    if (totalCount == 0) return [];

    var sortedEntries = _globalDistractionStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sortedEntries.take(3);

    return top3.map((e) {
      final percentage = ((e.value / totalCount) * 100).toStringAsFixed(0);
      return {"name": e.key, "percentage": "$percentage%"};
    }).toList();
  }

  Future<void> fetchAllAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchGlobalFocusHistory(),
        _fetchGlobalDistractionStats(),
      ]);
    } catch (e) {
      debugPrint('Error fetching admin analytics: $e');
      _errorMessage = 'Failed to load analytics. Check console for Index URL.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchGlobalFocusHistory() async {
    final querySnapshot = await _firestore
        .collectionGroup('dailyProgress')
        .orderBy('date', descending: true)
        .limit(500)
        .get();

    Map<String, int> tempDateMap = {};

    for (var doc in querySnapshot.docs) {
      final data = DailyProgressModel.fromFirestore(doc);
      if (tempDateMap.containsKey(data.date)) {
        tempDateMap[data.date] = tempDateMap[data.date]! + data.focusedMinutes;
      } else {
        tempDateMap[data.date] = data.focusedMinutes;
      }
    }

    _globalFocusHistory = tempDateMap.entries.map((entry) {
      return DailyProgressModel(
        date: entry.key,
        focusedMinutes: entry.value,
        updatedAt: DateTime.now(),
      );
    }).toList();

    _globalFocusHistory.sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _fetchGlobalDistractionStats() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final querySnapshot = await _firestore
        .collectionGroup('distractionLogs')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    Map<String, int> tempCategoryMap = {};

    for (var doc in querySnapshot.docs) {
      final log = DistractionLogModel.fromFirestore(doc);
      final category = log.category;
      if (tempCategoryMap.containsKey(category)) {
        tempCategoryMap[category] = tempCategoryMap[category]! + 1;
      } else {
        tempCategoryMap[category] = 1;
      }
    }
    _globalDistractionStats = tempCategoryMap;
  }
}
