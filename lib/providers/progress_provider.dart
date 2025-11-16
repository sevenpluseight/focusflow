import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/daily_progress_model.dart';
import 'package:intl/intl.dart';

class ProgressProvider with ChangeNotifier {
  String _uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => _uid;

  /// Setter to update UID and fetch new progress
  set uid(String newUid) {
    if (_uid != newUid) {
      _uid = newUid;
      fetchDailyProgress();
      notifyListeners();
    }
  }

  /// Map of 'yyyy-MM-dd' => DailyProgressModel
  final Map<String, DailyProgressModel> _dailyFocusMap = {};

  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastFocusDate;

  ProgressProvider({required String uid}) : _uid = uid;

  /// Fetch all daily progress documents for the user
  Future<void> fetchDailyProgress() async {
    if (_uid.isEmpty) return;

    // Fetch all daily progress docs
    final query = await _db
        .collection('users')
        .doc(_uid)
        .collection('dailyProgress')
        .get();

    _dailyFocusMap
      ..clear()
      ..addEntries(query.docs.map((doc) {
        final progress = DailyProgressModel.fromFirestore(doc);
        return MapEntry(doc.id, progress);
      }));

    // Fetch streaks and last focus date from the main user doc
    final userDoc = await _db.collection('users').doc(_uid).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      currentStreak = data['currentStreak'] ?? 0;
      longestStreak = data['longestStreak'] ?? 0;

      final lastFocusTimestamp = data['lastFocusDate'] as Timestamp?;
      lastFocusDate = lastFocusTimestamp?.toDate();
    }

    notifyListeners();
  }

  /// Minutes focused today
  int get minutesFocusedToday {
    final todayKey = _todayKey();
    return _dailyFocusMap[todayKey]?.focusedMinutes ?? 0;
  }

  /// Fraction of daily target completed (0.0 – 1.0)
  double todayProgress(double dailyTargetHours) {
    final minutesToday = minutesFocusedToday;
    return dailyTargetHours > 0
        ? (minutesToday / (dailyTargetHours * 60)).clamp(0.0, 1.0)
        : 0.0;
  }

  /// Formatted progress for display
  String getFormattedProgress(double dailyTargetHours) {
    final minutesToday = minutesFocusedToday;
    if (minutesToday < 60) {
      final targetMinutes = (dailyTargetHours * 60).round();
      return "$minutesToday / $targetMinutes min";
    } else {
      final hoursToday = minutesToday / 60;
      return "${hoursToday.toStringAsFixed(1)} / ${dailyTargetHours.toStringAsFixed(1)} hrs";
    }
  }

  /// Called when a focus session ends
  Future<void> endSession(int durationSeconds) async {
    if (_uid.isEmpty) return;

    final minutes = (durationSeconds / 60).round();
    final todayKey = _todayKey();

    final dailyDocRef =
        _db.collection('users').doc(_uid).collection('dailyProgress').doc(todayKey);
    final userRef = _db.collection('users').doc(_uid);

    await _db.runTransaction((tx) async {
      final dailySnapshot = await tx.get(dailyDocRef);
      final userSnap = await tx.get(userRef);

      // Current minutes
      final previousMinutes = dailySnapshot.exists
          ? (dailySnapshot.data()?['focusedMinutes'] as int? ?? 0)
          : 0;
      final newMinutes = previousMinutes + minutes;

      // Streak logic
      int newStreak = userSnap.data()?['currentStreak'] ?? 0;
      int newLongest = userSnap.data()?['longestStreak'] ?? 0;
      final lastFocusTimestamp = userSnap.data()?['lastFocusDate'] as Timestamp?;
      final lastDate = lastFocusTimestamp?.toDate();

      if (lastDate == null) {
        newStreak = 1;
        newLongest = 1;
      } else {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastFocusDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final diffDays = today.difference(lastFocusDay).inDays;

        if (diffDays == 1) {
          newStreak += 1;
          if (newStreak > newLongest) newLongest = newStreak;
        } else if (diffDays > 1) {
          newStreak = 1;
        }
      }

      // Update Firestore
      final newProgress = DailyProgressModel(
        date: todayKey,
        focusedMinutes: newMinutes,
        updatedAt: DateTime.now(),
      );
      tx.set(dailyDocRef, newProgress.toMap(), SetOptions(merge: true));

      tx.update(userRef, {
        'currentStreak': newStreak,
        'longestStreak': newLongest,
        'lastFocusDate': Timestamp.now(),
      });

      // Update local state
      _dailyFocusMap[todayKey] = newProgress;
      currentStreak = newStreak;
      longestStreak = newLongest;
      lastFocusDate = DateTime.now();
    });

    notifyListeners();
  }

  /// Skip break (doesn't modify Firestore)
  void skipBreak() => notifyListeners();

  /// Helper: Today key in 'yyyy-MM-dd' format
  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());
}
