/* TODO - Comment out or remove debug printing */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double todayProgress = 0.0; // 0.0 - 1.0
  int todayMinutes = 0;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _progressStream;

  /// Listen to today's progress for given user
  void listenTodayProgress(String uid, double dailyTargetHours) {
    final docId = _getTodayId();

    // Debug printing start
    print("[ProgressProvider] Listening to $uid / dailyProgress/$docId");
    // Debug printing end

    _progressStream = _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(docId)
        .snapshots();

    _progressStream!.listen((snapshot) {
      // Debug printing start
      print("[ProgressProvider] Snapshot exists: ${snapshot.exists}, data: ${snapshot.data()}");
      // Debug printing end

      int minutes = 0;
      if (snapshot.exists) {
        final data = snapshot.data();
        final numValue = data?['minutesFocused'];
        if (numValue != null) {
          minutes = (numValue as num).toInt();
        }
      }

      todayMinutes = minutes;
      todayProgress =
          (dailyTargetHours > 0) ? (minutes / 60 / dailyTargetHours) : 0.0;

      // Debug printing start
      print("[ProgressProvider] todayMinutes: $todayMinutes, todayProgress: $todayProgress");
      // Debug printing end

      notifyListeners();
    });
  }

  /// Add focus minutes (from a session)
  Future<void> addFocusMinutes(String uid, int minutesToAdd) async {
    final docId = _getTodayId();
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(docId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      int newMinutes = minutesToAdd;
      if (snapshot.exists) {
        final existingNum = snapshot.data()?['minutesFocused'];
        final existingMinutes = existingNum != null ? (existingNum as num).toInt() : 0;
        newMinutes += existingMinutes;
      }

      transaction.set(docRef, {
        'date': docId,
        'minutesFocused': newMinutes,
      });

      // Debug printing start
      print("[ProgressProvider] Added $minutesToAdd minutes. Total now: $newMinutes");
      // Debug printing end
    });
  }

  /// Date doc ID: resets at 4 AM
  String _getTodayId() {
    final now = DateTime.now();
    final adjusted = now.hour < 4
        ? now.subtract(const Duration(days: 1))
        : now;
    return "${adjusted.year.toString().padLeft(4, '0')}-"
        "${adjusted.month.toString().padLeft(2, '0')}-"
        "${adjusted.day.toString().padLeft(2, '0')}";
  }

  /// Format progress like "5 m / 2h" or "1 h / 2h"
  String getFormattedProgress(double dailyTargetHours) {
    if (todayMinutes < 60) {
      return '$todayMinutes m / ${dailyTargetHours.toStringAsFixed(0)}h';
    } else {
      final hours = todayMinutes ~/ 60;
      final minutes = todayMinutes % 60;
      if (minutes == 0) {
        return '$hours h / ${dailyTargetHours.toStringAsFixed(0)}h';
      } else {
        return '$hours h $minutes m / ${dailyTargetHours.toStringAsFixed(0)}h';
      }
    }
  }
}
