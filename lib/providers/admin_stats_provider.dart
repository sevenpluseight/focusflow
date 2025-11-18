import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:focusflow/services/services.dart';

class AdminStatsProvider with ChangeNotifier {
  final AdminStatService _statsService;

  AdminStatsProvider({AdminStatService? statsService})
    : _statsService = statsService ?? AdminStatService();

  // state for stats
  Map<String, int> _userCounts = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  // int _totalFocusMinutesToday = 0;
  // int _totalFocusMinutesThisWeek = 0;
  // List<MapEntry<String, int>> _topDistractions = [];

  StreamSubscription<Map<String, int>>? _userCountsSubscription;

  // getters
  Map<String, int> get userCounts => _userCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  int get totalUsers => _userCounts['total'] ?? 0;
  int get activeCoaches => _userCounts['coach'] ?? 0;
  int get activeUsers => _userCounts['user'] ?? 0;

  // String get totalFocusTodayHours {
  //   return (_totalFocusMinutesToday / 60).toStringAsFixed(1);
  // }

  // String get totalFocusThisWeekHours {
  //   return (_totalFocusMinutesThisWeek / 60).toStringAsFixed(1);
  // }

  // List<MapEntry<String, int>> get topDistractions => _topDistractions;

  void ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startListeningToStats();
    // _fetchSystemFocusTrends();
    // _fetchSystemDistractions();
  }

  void _startListeningToStats() {
    _userCountsSubscription = _statsService.getUserCountsStream().listen(
      (counts) {
        _userCounts = counts;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load user counts: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Future<void> _fetchSystemFocusTrends() async {
  //   try {
  //     final snapshot = await _db
  //         .collectionGroup('dailyProgress')
  //         .orderBy('date', descending: true)
  //         .limit(7)
  //         .get();

  //     if (snapshot.docs.isEmpty) {
  //       notifyListeners();
  //       return;
  //     }

  //     final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //     int todayMinutes = 0;
  //     int weekMinutes = 0;

  //     final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  //     for (final doc in snapshot.docs) {
  //       final data = doc.data();
  //       final minutes = (data['focusedMinutes'] as num? ?? 0).toInt();
  //       final date = data['date'] as String;

  //       // Check for today
  //       if (date == todayKey) {
  //         todayMinutes += minutes;
  //       }

  //       // Check for this week
  //       final docDate = DateTime.parse(date);
  //       if (docDate.isAfter(sevenDaysAgo)) {
  //         weekMinutes += minutes;
  //       }
  //     }

  //     _totalFocusMinutesToday = todayMinutes;
  //     _totalFocusMinutesThisWeek = weekMinutes;
  //   } catch (e) {
  //     debugPrint("Error fetching system focus trends: $e");
  //     _errorMessage = "Could not load focus trends. Index may be building.";
  //   }
  //   notifyListeners();
  // }

  // Future<void> _fetchSystemDistractions() async {
  //   try {
  //     final snapshot = await _db
  //         .collectionGroup('distractionLogs')
  //         .orderBy('createdAt', descending: true)
  //         .limit(100)
  //         .get();

  //     if (snapshot.docs.isEmpty) {
  //       notifyListeners();
  //       return;
  //     }

  //     final categoryCounts = <String, int>{};
  //     for (final doc in snapshot.docs) {
  //       final category = doc.data()['category'] as String? ?? 'Other';
  //       categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
  //     }

  //     final sortedList = categoryCounts.entries.toList()
  //       ..sort((a, b) => b.value.compareTo(a.value));
  //     _topDistractions = sortedList.take(3).toList();
  //   } catch (e) {
  //     debugPrint("Error fetching system distractions: $e");
  //     _errorMessage = "Could not load distractions. Index may be building.";
  //   }
  //   notifyListeners();
  // }

  void reset() {
    _userCountsSubscription?.cancel();
    _userCountsSubscription = null;
    _userCounts = {};
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    // _totalFocusMinutesToday = 0;
    // _totalFocusMinutesThisWeek = 0;
    // _topDistractions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _userCountsSubscription?.cancel();
    super.dispose();
  }
}
