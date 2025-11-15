import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
// import 'package:flutter/material.dart';

class AdminStatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _stats => _firestore.collection('adminStats');

  // for live user count
  Stream<Map<String, int>> getUserCountsStream() {
    return _stats.doc('users').snapshots().map((doc) {
      if (!doc.exists) {
        return {'user': 0, 'coach': 0, 'admin': 0, 'total': 0};
      }
      final data = doc.data() as Map<String, dynamic>;
      return {
        'user': data['userCount'] ?? 0,
        'coach': data['coachCount'] ?? 0,
        'admin': data['adminCount'] ?? 0,
        'total': data['totalCount'] ?? 0,
      };
    });
  }

  // batch update
  // use this to increment or decrement user count (not recommeded for role change)
  void updateUserCount(WriteBatch batch, String role, bool isIncrement) {
    final int amount = isIncrement ? 1 : -1;
    final userStatsDoc = _stats.doc('users');
    batch.set(userStatsDoc, {
      '${role}Count': FieldValue.increment(amount),
      'totalCount': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  // batch update
  // only swaps counts, does not update total
  void updateUserRoleCount(WriteBatch batch, String oldRole, String newRole) {
    final userStatsDoc = _stats.doc('users');
    batch.set(userStatsDoc, {
      '${oldRole}Count': FieldValue.increment(-1),
      '${newRole}Count': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // individual update
  Future<void> updateUserCountIndiv(String role, bool isIncrement) async {
    final int amount = isIncrement ? 1 : -1;
    final userStatsDoc = _stats.doc('users');
    await userStatsDoc.set({
      '${role}Count': FieldValue.increment(amount),
      'totalCount': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  // only when needed!
  // reset all counts to 0
  Future<void> resetStats() async {
    try {
      final batch = _firestore.batch();
      batch.set(_stats.doc('users'), {
        'userCount': 0,
        'coachCount': 0,
        'adminCount': 0,
        'totalCount': 0,
      }, SetOptions(merge: true));

      // when there are others, initialize here too

      await batch.commit();
    } catch (e) {
      developer.log(
        'Error initializing stats',
        error: e,
        name: 'AdminStatsService',
      );
      rethrow;
    }
  }

  // calculate all stats again
  Future<void> recalculateAllStats() async {
    try {
      // Count actual users
      final usersSnapshot = await _firestore.collection('users').get();
      int userCount = 0;
      int coachCount = 0;
      int adminCount = 0;

      for (final doc in usersSnapshot.docs) {
        final role = doc.data()['role'] as String? ?? 'user';
        switch (role) {
          case 'user':
            userCount++;
            break;
          case 'coach':
            coachCount++;
            break;
          case 'admin':
            adminCount++;
            break;
        }
      }

      // Update stats document
      await _stats.doc('users').set({
        'userCount': userCount,
        'coachCount': coachCount,
        'adminCount': adminCount,
        'totalCount': userCount + coachCount + adminCount,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastRecalculated': FieldValue.serverTimestamp(),
      });

      developer.log(
        'Stats recalculated: users=$userCount, coaches=$coachCount, admins=$adminCount',
        name: 'AdminStatsService',
      );
    } catch (e) {
      developer.log(
        'Error recalculating stats',
        error: e,
        name: 'AdminStatsService',
      );
      rethrow;
    }
  }
}
