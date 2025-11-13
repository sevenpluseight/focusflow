import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/models.dart';

class UserProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  void _safeNotifyListeners() {
    // Delay notifyListeners to avoid calling during build
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  Future<void> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
    required double dailyTargetHours,
    required int workInterval,
    required int breakInterval,
    required String focusType,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);

    final newUser = UserModel(
      uid: uid,
      username: username,
      email: email,
      role: 'user',
      signInMethod: 'email',
      createdAt: Timestamp.now(),
      dailyTargetHours: dailyTargetHours,
      workInterval: workInterval,
      breakInterval: breakInterval,
      focusType: focusType,
      currentStreak: 0,
      longestStreak: 0,
      lastFocusDate: null,
    );

    await userDoc.set(newUser.toMap(), SetOptions(merge: true));
    _user = newUser;
    _safeNotifyListeners();
  }

  Future<void> updateStreak() async {
    if (_user == null) return;
    final userRef = _firestore.collection('users').doc(_user!.uid);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastFocusDate = _user!.lastFocusDate?.toDate();
    int currentStreak = _user!.currentStreak ?? 0;
    int longestStreak = _user!.longestStreak ?? 0;

    if (lastFocusDate != null) {
      final diff = today.difference(lastFocusDate).inDays;
      if (diff == 1) {
        currentStreak += 1;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
      longestStreak = 1;
    }

    await userRef.update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastFocusDate': today,
    });

    await fetchUser();
  }

  Future<void> updateSettings({
    double? dailyTargetHours,
    int? workInterval,
    int? breakInterval,
    String? focusType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (dailyTargetHours != null) updates['dailyTargetHours'] = dailyTargetHours;
    if (workInterval != null) updates['workInterval'] = workInterval;
    if (breakInterval != null) updates['breakInterval'] = breakInterval;
    if (focusType != null) updates['focusType'] = focusType;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
      await fetchUser();
    }
  }
}
