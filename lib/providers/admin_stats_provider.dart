import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:focusflow/services/services.dart';

class AdminStatsProvider with ChangeNotifier {
  final AdminStatService _statsService;

  AdminStatsProvider({AdminStatService? statsService})
    : _statsService = statsService ?? AdminStatService();

  // state for statss
  Map<String, int> _userCounts = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  // manage stream connection
  StreamSubscription<Map<String, int>>? _userCountsSubscription;

  // getters
  Map<String, int> get userCounts => _userCounts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // fields computed
  int get totalUsers => _userCounts['total'] ?? 0;
  int get activeCoaches => _userCounts['coach'] ?? 0;

  void ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startListeningToStats();
  }

  void _startListeningToStats() {
    // _isLoading = true;
    // notifyListeners();

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

  void reset() {
    _userCountsSubscription?.cancel();
    _userCountsSubscription = null;

    _userCounts = {};
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _userCountsSubscription?.cancel();
    super.dispose();
  }
}
