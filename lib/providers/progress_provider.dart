import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double todayProgress = 0.0;
  int todayMinutes = 0;
  double _dailyTargetHours = 2.0;

  StreamSubscription? _progressSubscription;
  StreamSubscription? _userSubscription;
  StreamSubscription? _authSubscription;

  ProgressProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToData(user.uid);
      } else {
        cancelSubscriptions();
        _resetState();
      }
    });
  }

  @override
  void dispose() {
    cancelSubscriptions();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToData(String uid) {
    cancelSubscriptions(); // Cancel any existing listeners

    // Listen to user data for target updates
    final userStream = _firestore.collection('users').doc(uid).snapshots();
    _userSubscription = userStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final numTarget = data?['dailyTargetHours'];
        if (numTarget != null) {
          final newTarget = (numTarget as num).toDouble();
          if (newTarget != _dailyTargetHours) {
            _dailyTargetHours = newTarget;
            _recalculateProgress();
            notifyListeners();
          }
        }
      }
    });

    // Listen to today's progress
    final docId = _getTodayId();
    final progressStream = _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(docId)
        .snapshots();

    _progressSubscription = progressStream.listen((snapshot) {
      int minutes = 0;
      if (snapshot.exists) {
        final data = snapshot.data();
        final numValue = data?['minutesFocused'];
        if (numValue != null) {
          minutes = (numValue as num).toInt();
        }
      }
      todayMinutes = minutes;
      _recalculateProgress();
      notifyListeners();
    });
  }

  void _recalculateProgress() {
    todayProgress =
        (_dailyTargetHours > 0) ? (todayMinutes / 60 / _dailyTargetHours) : 0.0;
  }

  void cancelSubscriptions() {
    _progressSubscription?.cancel();
    _userSubscription?.cancel();
  }

  void _resetState() {
    todayProgress = 0.0;
    todayMinutes = 0;
    _dailyTargetHours = 2.0;
    notifyListeners();
  }

  Future<void> addFocusMinutes(int minutesToAdd) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

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
        final existingMinutes =
            existingNum != null ? (existingNum as num).toInt() : 0;
        newMinutes += existingMinutes;
      }
      transaction.set(
          docRef, {'date': docId, 'minutesFocused': newMinutes});
    });
  }

  String _getTodayId() {
    final now = DateTime.now();
    final adjusted = now.hour < 4 ? now.subtract(const Duration(days: 1)) : now;
    return "${adjusted.year.toString().padLeft(4, '0')}-"
        "${adjusted.month.toString().padLeft(2, '0')}-"
        "${adjusted.day.toString().padLeft(2, '0')}";
  }

  String getFormattedProgress(double dailyTargetHours) {
    final target = _dailyTargetHours;
    if (todayMinutes < 60) {
      return '$todayMinutes m / ${target.toStringAsFixed(0)}h';
    } else {
      final hours = todayMinutes ~/ 60;
      final minutes = todayMinutes % 60;
      if (minutes == 0) {
        return '$hours h / ${target.toStringAsFixed(0)}h';
      } else {
        return '$hours h $minutes m / ${target.toStringAsFixed(0)}h';
      }
    }
  }
}
